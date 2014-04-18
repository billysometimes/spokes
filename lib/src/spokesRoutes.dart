part of spokes;

class SpokesRoutes {

  manage(HttpRequest request){

      if(!tryAndServe(request)){
        Function ctrl;
        SpokesRequest req;
        this.urls.forEach((k,v){
          Map match = _matches(k,request);
          if(match["match"]){
            ctrl = v;
            req = match["request"];
          }
        });
        if(ctrl != null){
          ctrl(req);
        }
        else{
          //serve 404
          request.response.statusCode = HttpStatus.NOT_FOUND;
          request.response.close();
        }
    }
  }

  tryAndServe(HttpRequest request){
    String path = PUBLIC_PATH+_fixUri(request);
    if(new File(path).existsSync()){
      var extension= path.substring(path.indexOf("."));
      if(extension == ".svg"){
        request.response.headers.add("Accept-Ranges", "bytes");
        request.response.headers.add("Content-Type", "image/svg+xml");
      }
      new File(path).openRead().pipe(request.response).then((d){request.response.close();});
      return true;
   }else if(request.uri.pathSegments.isNotEmpty && request.uri.pathSegments[0] == "packages" && new File(BASE_PATH+_fixUri(request)).existsSync()){
     new File(BASE_PATH+_fixUri(request)).openRead().pipe(request.response).then((d){request.response.close();});
     return true;
   }
    return false;
 }


  String _fixUri(HttpRequest request){
    var builtPath = request.uri.path;
    if(request.uri.pathSegments.isNotEmpty && request.uri.pathSegments.last.indexOf(".") == -1)
      builtPath +=".html";
    return builtPath;
  }


  Map _matches(SpokesUrl p, HttpRequest req) {
    print(req.method);
    var match = true;
         Map params = {};
         Map returnVal = {};
         List url = new List.from(p.uri.pathSegments);
         List reqUrl = req.uri.pathSegments;
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
         returnVal["match"] = match;
         if(match){
           SpokesRequest r = new SpokesRequest(req);
           r.params.addAll(params);
           r.setUri(url.join("/"));
           returnVal["request"] = r;
         }
        return returnVal;
       }

   Map urls;
}
