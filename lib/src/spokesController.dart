part of spokes;

class SpokesController {

  render(SpokesRequest request, [Map params,String template]){
    var path = request.uri.path;
    if(template !=null){
      path = template;
    }
     templateEngine.render(path,params).then((msg){
      request.response.write(msg);
      var middlewareRequest = request;
      for(final e in middleWares){
        try{
          middlewareRequest = e.processTemplateResponse(middlewareRequest);
          middlewareRequest = e.processResponse(middlewareRequest);
        }on NoSuchMethodError{

        }catch(e){
          print(e);
        }
      }
      if(middlewareRequest is Future){
        middlewareRequest.then((SpokesRequest r){
          if(!r.response.isDone){
            r.response.close();
          }
        });
      }else{
        if(!middlewareRequest.response.isDone){
          middlewareRequest.response.close();
        }
      }
    }).catchError((error){

       request.response.write(error);
       var middlewareRequest = request;
       for(final e in middleWares){
         try{
           middlewareRequest = e.processResponse(request);
           middlewareRequest = e.processException(request,error);
         }on NoSuchMethodError{

         }catch(e){
           print(e);
         }
       }
       if(middlewareRequest is Future){
         middlewareRequest.then((SpokesRequest r){
           if(!r.response.isDone){
             r.response.close();
           }
         });
       }else{
         if(!middlewareRequest.response.isDone){
           middlewareRequest.response.close();
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
      var middlewareRequest = request;
      for(final e in middleWares){
        try{
          middlewareRequest = e.processResponse(middlewareRequest);
        }on NoSuchMethodError{

        }catch(e){
          print(e);
        }
      }
      if(middlewareRequest is Future){
        middlewareRequest.then((SpokesRequest r){
          if(!r.response.isDone)
            r.response.close();
        });
      }else{
        if(!middlewareRequest.response.isDone){
          middlewareRequest.response.close();
        }
      }
    });
  }

  sendJSON(SpokesRequest request,var jsonData){
    request.response..headers.set(HttpHeaders.CONTENT_TYPE, 'application/json');
    request.response..headers..write(JSON.encode(jsonData));
    var middlewareRequest = request;
    for(final e in middleWares){
      try{
        middlewareRequest = e.processResponse(middlewareRequest);
      }on NoSuchMethodError{

      }catch(e){
        print(e);
      }
    }
    if(middlewareRequest is Future){
      middlewareRequest.then((SpokesRequest r){
        if(!r.response.isDone)
          r.response.close();
      });
    }else{
      if(!middlewareRequest.response.isDone){
        middlewareRequest.response.close();
      }
    }

  }
}