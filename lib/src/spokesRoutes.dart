part of spokes;

  class SpokesRoutes {

    manage(SpokesRequest request){
      var served = tryAndServe(request);
      Function ctrl;
      if(!served){
        this.urls.forEach((k,v){
          bool match = _matches(k,request);
          if(match){
            ctrl = v;
          }
        });

        var middleWareRequest = request;
        for(final e in middleWares){
          try{
            middleWareRequest = e.processController(middleWareRequest,ctrl);
          }on NoSuchMethodError{

          }catch(e){
            print(e);
          }
        }
        if(!request.response.isDone && ctrl != null)
          ctrl(request);

        if(ctrl == null){
          if(!request.response.isDone){
            request.response.statusCode = HttpStatus.NOT_FOUND;
            request.response.close();
          }
        }
      }

    }

    tryAndServe(SpokesRequest request){
      var path = _fixUri(request);

      if(new File(path).existsSync()){
        var extension= path.substring(path.indexOf("."));
        if(extension == ".svg"){
          request.response.headers.add("Accept-Ranges", "bytes");
          request.response.headers.add("Content-Type", "image/svg+xml");
        }
        new File(path).openRead().pipe(request.response).then((d){
          request.response.close();
        });
        return true;
     }
      return false;
   }


    String _fixUri(SpokesRequest request){
      List builtPath = new List.from(request.request.uri.pathSegments);
      if(builtPath.isNotEmpty && builtPath.first != "packages")
        builtPath.insert(0, PUBLIC_PATH);
      if(builtPath.isNotEmpty)
        builtPath.insert(0, BASE_PATH);

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


