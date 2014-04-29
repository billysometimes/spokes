part of spokes;

class SpokesController{


  List beforeFilters;

  List afterFilters;

  render(SpokesRequest request, [Map params,String template]){
    var path = request.uri.path;
    if(template !=null){
      path = template;
    }
     request.renderFunction = templateEngine.render;
     for(final e in middleWares){
       try{
         if(!request.response.isDone)
           e.processTemplateResponse(request,params);
       }on NoSuchMethodError{

       }catch(error){
         print(error);
       }

       try{
         if(!request.response.isDone)
           e.processResponse(request);
         }on NoSuchMethodError{

         }catch(error){
           print(error);
         }
     }

    if(!request.response.isDone) {
       request.renderFunction(path,params).then((msg){
         request.response.write(msg);

         request.response.close();
      }).catchError((error){

       request.response.write(error);

       for(final e in middleWares){
         try{
         if(!request.response.isDone)
           e.processException(request,error);
         }on NoSuchMethodError{

         }catch(error){
           print(error);
         }
         try{
         if(!request.response.isDone)
           e.processResponse(request);
         }on NoSuchMethodError{

         }catch(error){
           print(error);
         }
       }
       if(!request.response.isDone){
         request.response.close();
         }
      });
    }
  }

  serve(SpokesRequest request,String fileName){
    var path = BASE_PATH+Platform.pathSeparator+fileName;

    request.renderFunction = new File(path).openRead().pipe;

    for(final e in middleWares){
      try{
      if(!request.response.isDone)
        e.processResponse(request);
      }on NoSuchMethodError{

      }catch(error){
       print(error);
      }
    }

    request.renderFunction(request.response).then((d){

        if(!request.response.isDone){
          request.response.close();
        }
    });
  }

  redirect(SpokesRequest req,String location,{statusCode: HttpStatus.TEMPORARY_REDIRECT}){
    req.response.headers.set(HttpHeaders.LOCATION,location);
    req.response.statusCode = statusCode;
    req.response.close();
  }

  sendJSON(SpokesRequest request,var jsonData){
    request.response..headers.set(HttpHeaders.CONTENT_TYPE, 'application/json');
    request.response..headers..write(JSON.encode(jsonData));

    for(final e in middleWares){
      try{
        if(!request.response.isDone)
          e.processResponse(request);
      }on NoSuchMethodError{

      }catch(error){
        print(error);
      }
    }

    if(!request.response.isDone){
        request.response.close();
      }
    }
}