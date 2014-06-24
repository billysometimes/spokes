part of spokes;

  class SpokesRoutes{

    manage(SpokesRequest request){
      var served = _tryAndServe(request);
      Function ctrl;
      Function done;
      Function connected;
      Function data;

      String onConnect;
      String onDone;
      String onData;
      StreamController ws;
      var d;
      if(!served){
        this.urls.forEach((k,Map<String,Object>v){
          bool match = _matches(k,request);
          if(match){

            Object cls = v["controller"];

            ClassMirror cm = reflectClass(cls);
            var ncm = cm.newInstance(new Symbol(""),[]);

            List beforeFilters = ncm.getField(new Symbol("beforeFilters")).reflectee;

            if(beforeFilters != null){
              beforeFilters.forEach((Map filter){
                if(filter["only"] == null || filter["only"].contains(v["action"])){
                  request.beforeFilters.add(filter["action"]);
                }
              });
            }

            List afterFilters = ncm.getField(new Symbol("afterFilters")).reflectee;

            if(afterFilters != null){
              afterFilters.forEach((Map filter){
                if(filter["only"] == null || filter["only"].contains(v["action"])){
                  request.afterFilters.add(filter["action"]);
                }
              });

            }

            if(WebSocketTransformer.isUpgradeRequest(request.request)){
              ws = v["ws"];
              onDone = v["onDone"];
              onConnect = v["onConnect"];
              onData = v["onData"];

              if(onDone != null){
                done = ncm.getField(new Symbol(onDone)).reflectee;
              }
              if(onConnect != null){
                connected = ncm.getField(new Symbol(onConnect)).reflectee;
              }
              if(onData != null){
                data = ncm.getField(new Symbol(onData)).reflectee;
              }
            }else{
              if(cls != null){
                ctrl = ncm.getField(new Symbol(v["action"])).reflectee;
              }
            }

          }
        });

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
        if(!request.response.isDone){
          if(WebSocketTransformer.isUpgradeRequest(request.request)){
            if(ws == null){
              ws = new StreamController();
            }
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
          }else{
          try{
            ctrl(request);
          }catch(error){
            request.response.write(error);
            request.response.close();
          }
          }
        }

        if(ctrl == null){
          if(!request.response.isDone){
            request.response.statusCode = HttpStatus.NOT_FOUND;
            request.response.close();
          }
        }
      }

    }

    _tryAndServe(SpokesRequest request){
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


    bool _matches(SpokesUrl p, SpokesRequest req) {
      var match = true;
      Map params = {};
      List url = new List.from(p.uri.pathSegments);
      List reqUrl = req.request.uri.pathSegments;

      if(!p.methods.contains(req.method)){
        match = false;
      }else if(url.length != reqUrl.length){
        match = false;
      }else{
        for(var i=0;i<reqUrl.length;i++){
          if(url.length != reqUrl.length){
            match = false;
          }
          if(url[i].startsWith(":")){
            params[url[i].replaceAll(":", "")] =reqUrl[i];
            url.removeAt(i);
          }else if(url[i] != reqUrl[i]){
            match = false;
          }
        }
      }
      if(match){
        req.params.addAll(params);
        req.setUri(url.join("/"));

      }
      return match;
    }

     Map urls;
  }


