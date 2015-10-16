part of spokes;

class SpokesRouter{
  _RouteTrie _routes = new _RouteTrie();

  var _urls = new Map();

  processRequest(SpokesRequest request){
    Function match = _routes._matchRoute(request.uri.path, request);
    if(match != null){
      return match(request);
    }else{
      request.response.statusCode = HttpStatus.NOT_FOUND;
      return request;
    }
  }

  processResponse(SpokesRequest request){

   if(request.response.statusCode == HttpStatus.NOT_FOUND){
     request.response.write("ERROR: ${request.response.statusCode}");
   }
    return request;
  }

  addRoute(String method,String path, Function action){
    this._urls[new SpokesUrl(method,path)] = action;
    this._routes._addRoutes(this._urls);

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

