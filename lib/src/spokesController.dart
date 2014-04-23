part of spokes;

class SpokesController {

  render(SpokesRequest request, [Map params,String template]){
    var path = request.uri.path;
    print("SERVING:"+path);
    if(template !=null){
      path = template;
    }
     templateEngine.render(path,params).then((msg){
      for(final e in middleWares){
        try{
          e.processTemplateResponse(request);
          e.processResponse(request);
        }on NoSuchMethodError{

        }catch(e){
          print(e);
        }
      }
      if(!request.response.isDone){
        request.response.write(msg);
        request.response.close();
      }
    }).catchError((error){
       for(final e in middleWares){
         try{
           e.processResponse(request);
           e.processException(request,error);
         }on NoSuchMethodError{

         }catch(e){
           print(e);
         }
       }
       if(!request.response.isDone){
         try{
           request.response.write(error);
           request.response.close();
         }on NoSuchMethodError{

         }catch(e){
           print(e);
         }
       }
    });
  }

  serve(SpokesRequest request,[String fileName]){
    String path = BASE_PATH+request.uri.pathSegments.join(Platform.pathSeparator);
    if(fileName != null){
      path = BASE_PATH+fileName;
    }
    return new File(path).openRead().pipe(request.response).then((d){
      for(final e in middleWares){
        try{
          e.processResponse(request);
        }on NoSuchMethodError{

        }catch(e){
          print(e);
        }
      }
      request.response.close();
    });
  }

  sendJSON(SpokesRequest request,var jsonData){

    request.response..headers.set(HttpHeaders.CONTENT_TYPE, 'application/json');
    request.response..headers..write(JSON.encode(jsonData));
    for(final e in middleWares){
      try{
        e.processResponse(request);
      }on NoSuchMethodError{

      }catch(e){
        print(e);
      }
    }
    request.response.close();

  }
}