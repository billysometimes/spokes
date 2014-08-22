part of spokes;

class SpokesRoutes{
  RouteTrie routes = new RouteTrie();
  
  manage(SpokesRequest request){
    
    //try to serve static file if it exists
    var served = _tryAndServe(request);
          
    if(!served){
      
      //find a matching URL
      Map match = routes.matchRoute(request.uri.path, request);

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
          
          _runMiddlewares(request,ctrl);
          
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
        new SpokesController().serve(request,PUBLIC_PATH+"/404.html");
      }

    }

  }
    
  get urls => this.urls;

  bool _tryAndServe(SpokesRequest request){
    var path = _fixUri(request);
    if(new File(path).existsSync()){
      new SpokesController().serve(request, path);
      return true;
    }
    return false;
  }

  String _fixUri(SpokesRequest request){
    List builtPath = new List.from(request.request.uri.pathSegments);

    if(builtPath.isNotEmpty && builtPath.first != "packages")
      builtPath.insert(0, PUBLIC_PATH);


    if(builtPath.isNotEmpty && builtPath.last.indexOf(".") == -1)
      builtPath[builtPath.length-1] +=".html";
    
    return builtPath.isNotEmpty ? builtPath.join(Platform.pathSeparator) : "";
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
        ws.sink.add(data(request,msg));
      });

      socket.done.then((_){
        ws.sink.add(done(request));
      });
    });
    
  }
  
  void _runMiddlewares(request,ctrl){
    for(final e in middleWares){
      try{
        if(!request.response.isDone)
          e.processController(request,ctrl);
      }on NoSuchMethodError{

      }catch(error){
        request.response.write(error);
        request.response.close();
      }
    }
  }
  
  _init(){
    this.routes.addRoutes(this.urls);
  }
}
  
class RouteTrie {
  RouteNode _root;
  
  RouteTrie(){
    _root = new RouteNode();
  }
  addRoutes(Map routes){
    routes.forEach((SpokesUrl path,Map action){
      _root._addRoute(path.uri.path,action,path.methods);
      
    });
  }
  
  matchRoute(String route,SpokesRequest req){
    return _root._match(route,req);
  }
}

class RouteNode {
  Map val;
  String param;
  Map<String,RouteNode> children;
  List methods;
  
  RouteNode(){
    children = new Map();
  }
 
  _match(String route,SpokesRequest req){
    if(this.param != null){
      req.params[param] = new RegExp(r"(\w+)").stringMatch(route);
      req.setUri(req.uri.path.replaceFirst("/"+req.params[param], ""));
      route = route.substring(req.params[param].length);      
    }

    if(route.length > 0 && this.children[route[0]] != null){
      return this.children[route[0]]._match(route.substring(1),req);
    }
    else if(this.methods == null || !this.methods.contains(req.method)){
      return null;
    }
    else{
      return this.val;
    }
    
  }
  
  _addRoute(String path, Map action,List methods){
  
     String token = path[0];
     String remaining = path.substring(1);
     var nextNode;
     
     if(token == ":"){
         this.param = new RegExp(r"(\w+)").stringMatch(remaining);
         remaining = remaining.substring(this.param.length);
         if(remaining.length > 0){
           token = remaining[0];
           remaining = remaining.substring(1);
         }
     }
     if(remaining.length > 0){
       if(children[token] == null){
         children[token] = new RouteNode();
       }
       children[token]._addRoute(remaining,action,methods);
     }else{
       this.val = action;
       this.methods = methods;
     }
     
     
  }
}

