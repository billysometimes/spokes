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

      for(final e in middleWares){
        try{
          e.processController(request,ctrl);
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
    String path = PUBLIC_PATH+_fixUri(request);
    if(!request.request.uri.pathSegments.isEmpty && request.request.uri.pathSegments.first == "packages")
       path = BASE_PATH+_fixUri(request);
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
   }else if(request.request.uri.pathSegments.isNotEmpty && request.request.uri.pathSegments[0] == "packages" && new File(BASE_PATH+_fixUri(request)).existsSync()){
     new File(BASE_PATH+_fixUri(request)).openRead().pipe(request.response).then((d){
       request.response.close();
     });
     return true;
   }
    return false;
 }


  String _fixUri(SpokesRequest request){
    List builtPath = new List.from(request.request.uri.pathSegments);
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
