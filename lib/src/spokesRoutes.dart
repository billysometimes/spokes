part of spokes;

class SpokesRouter{
  _RouteTrie _routes = new _RouteTrie();

  var _urls = new Map();
  /**
   * Attempts to fulfill a request.  
   * 
   * First it attempts to serve a file if one matching the request path exists.
   * 
   * If there is no static file, a route is matched.
   * 
   * If no routes match, a 404 is returned.
   */
  processRequest(SpokesRequest request){
    var path = _fixUri(request);
    new File(path).exists().then((bool exists){
      if(exists){
        //try to serve static file if it exists
        new SpokesController().serve(request, path);
      }else{
        _routeUnservedRequest(request);
      }
    });

  }

  addRoute(String method,String path, Function action){
    this._urls[new SpokesUrl(method,path)] = action;
    this._routes._addRoutes(this._urls);

  }
    
  /**
   * Returns the routes defined in the routes.dart file.
   */
  Map get urls => this._urls;
  
  _routeUnservedRequest(SpokesRequest request){  
      //find a matching URL
      Function match = _routes._matchRoute(request.uri.path, request);
      if(match != null){
        match(request);
      }
      /**
      if(match != null){
        Function ctrl;
  
        Object cls = match["controller"];

        //create a new instance of the class that matches our controller
        ClassMirror cm = reflectClass(cls);
        var ncm = cm.newInstance(new Symbol(""),[]);

        //check if it is a websocket upgrade request
        if(WebSocketTransformer.isUpgradeRequest(request.request))
          _handleWebsocket(request,ncm,match);
        else{
          //handle http request
          if(cls != null)
            ctrl = ncm.getField(new Symbol(match["action"])).reflectee;
          
          _runMiddlewares(request,ctrl,0);
          
          if(!request.response.isDone){
            try{
              ctrl(request);
            }catch(error){
              request.response.write(error);
              request.response.close();
            }
          }
        }
      }else{
        //File does not exist and no route exists
        new SpokesController().serve(request,"web/404.html");
      }**/
  }

  String _fixUri(SpokesRequest request){
    //List builtPath = new List.from(request.request.uri.pathSegments);

    //if(builtPath.isNotEmpty && builtPath.first != "packages")
    //builtPath.insert(0, PUBLIC_PATH);


    //if(builtPath.isNotEmpty && builtPath.last.indexOf(".") == -1)
    //  builtPath[builtPath.length-1] +=".html";
    
    //return builtPath.isNotEmpty ? builtPath.join(Platform.pathSeparator) : "";
    return request.request.uri.toString();
  }

  void _handleWebsocket(request,ncm,match){
   
    Function done;
    Function connected;
    Function data;
    
    StreamController ws = match["ws"] == null ? new StreamController() : match["ws"];
    String onDone = match["onDone"];
    String onConnect = match["onConnect"];
    String onData = match["onData"];

    if(onDone != null)
      done = ncm.getField(new Symbol(onDone)).reflectee;
      
    if(onConnect != null)
      connected = ncm.getField(new Symbol(onConnect)).reflectee;
        
    if(onData != null)
      data = ncm.getField(new Symbol(onData)).reflectee;
        
    WebSocketTransformer.upgrade(request.request).then((WebSocket socket) {
      ws.stream.pipe(socket);
      ws.sink.add(connected(request));
      socket.listen((var msg) {
        ws.sink.add(data(socket,request,msg));
      });

      socket.done.then((_){
        ws.sink.add(done(request));
      });
    });
    
  }
  
  void _runMiddlewares(request,ctrl,int mw){
    if(!request.response.isDone){
      if(mw < middleWares.length){
        try{
          var v = middleWares[mw].processController(request,ctrl);
          if(v is Future){
            v.then((req){
              _runMiddlewares(req,ctrl,++mw);
            });
          }else{
            _runMiddlewares(request,ctrl,++mw);
          }
        }on NoSuchMethodError{
          _runMiddlewares(request,ctrl,++mw);
        }catch(error){
          request.response.write(error);
          request.response.close();
        }
      }
    }
  }
  
  _init(){
    this._routes._addRoutes(this._urls);
    _routes.toString();
  }
}
  
class _RouteTrie {
  Map <String, _RouteNode> _root;
  
  _RouteTrie(){
      _root = {};
  }
  _addRoutes(Map routes){
    routes.forEach((var url,var action){
      if(url is SpokesResource){
        _addRoutes(url._buildResource(action));
      }else{
      url.methods.forEach((method){
        if(_root[method] == null){
          _root[method] = new _RouteNode();
        }       
        _RouteNode root = _root[method];      
        root._addRoute(url.uri.path,action);
      });
      }
    });
  }
  
  _matchRoute(String route,SpokesRequest req){
    if(_root[req.method] == null)
      return null;
    
    return _root[req.method]._match(route,req);
  }

}

class _RouteNode {
  Function route;
  _RouteNode param;
  String paramName;
  Map<String,_RouteNode> children;
  
  _match(String route,SpokesRequest req){
    var val;
     if(this.param != null && (route != "" || route == "/")){
       var p = new RegExp(r"(\w+)").stringMatch(route);
       if(p==null)
         p = "";
       
       req.setUri(req.uri.path.replaceFirst("/"+p, ""));

       val = this.param._match(route.substring(p.length), req);
       if(val != null){
         req.params[paramName] = new RegExp(r"(\w+)").stringMatch(route);
       }
     }
     
     if(route.length > 0 && this.children != null && this.children[route[0]] != null && val == null){
       return this.children[route[0]]._match(route.substring(1),req);
     }else if(this.route != null && (route.length == 0 || route == "/")){
       return this.route;
     }else{
       return val;
     }

    
  }
  
  _addRoute(String path, Function action){
    if(path.length == 0){
        this.route = action;
      }else{
        
        var token = path[0];
        var remaining = path.substring(1);
        var next;

        if(token[0] == ':'){

          var name = new RegExp(r"(\w+)").stringMatch(remaining);
          remaining = remaining.substring(name.length);
      
          if(this.param == null){
            this.param = new _RouteNode();
            this.paramName = name;
          }
          next = this.param;
        }else{

          if(this.children == null)
            this.children = new Map<String,_RouteNode>();
        
          if(this.children[token] == null)
            this.children[token] = new _RouteNode();
        
          next = this.children[token];
        }

        next._addRoute(remaining, action);
      }
  }
}

