part of spokes;

class SpokesRoutes{

  manage(SpokesRequest request){
    
    //try to serve static file if it exists
    var served = _tryAndServe(request);
    
    Function ctrl;
      
    if(!served){
      //find a matching URL
      Map match = _matches(urls,request);

      if(match != null){
  
        Object cls = match["controller"];

        ClassMirror cm = reflectClass(cls);
        var ncm = cm.newInstance(new Symbol(""),[]);

        if(WebSocketTransformer.isUpgradeRequest(request.request))
          _handleWebsocket(request,ncm,match);
        else{
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
        new SpokesController().redirect(request,"404.html");
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
  
  Map _matches(Map urls, SpokesRequest req){
    Map params = {};
    List reqUrl = req.request.uri.pathSegments;
    var ctrlClass = null;
    bool match = true;
    
    for(final k in urls.keys){
      var v = urls[k]; 
      List url = new List.from(k.uri.pathSegments);
      if(k.methods.contains(req.method) && url.length == reqUrl.length){
        for(var i=0;i<reqUrl.length;i++){
              
          //add params from URL to request params
          if(url[i].startsWith(":")){
            params[url[i].replaceAll(":", "")] =reqUrl[i];
            url.removeAt(i);
          }else if(url[i] != reqUrl[i]){
            match = false;
          }
              
        }
      }else{
        match = false;
      }
        
      if(match){
        req.params.addAll(params);
        req.setUri(url.join("/"));
        return v;
      }else{
          match = true;
        }
      }
      return null;
    }
  }
  
  

