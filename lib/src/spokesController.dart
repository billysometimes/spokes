/**
 * A class that defines the methods necessary to send data to a client.
 */

part of spokes;

class SpokesController{


  /**Content Types**/
  static final _HTML = ContentType.HTML;

  static final _CSS = new ContentType("text","css", charset: "utf-8");
  static final _DART = new ContentType("application","dart");
  static final _JAVASCRIPT = new ContentType("application","javascript");
  static final _JPEG = new ContentType("image","jpeg");
  static final _JSON = ContentType.JSON;
  static final _TEXT = ContentType.TEXT;
  static final _SVG  = new ContentType("image","svg+xml");
  static final _PNG  = new ContentType("image","png");
  static final _ICO  = new ContentType("image","x-icon");
  static final _TTF  = new ContentType("application","x-font-ttf");
  static final _MAP  = ContentType.JSON;


  /**Extensions**/
  static final _extensions = <String, ContentType>{
     'map': _MAP,
     'css': _CSS,
     'dart': _DART,
     'html': _HTML,
     'jpg': _JPEG,
     'js': _JAVASCRIPT,
     'json': _JSON,
     'txt': _TEXT,
     'svg': _SVG,
     'png': _PNG,
     'ico': _ICO,
     'ttf':_TTF

   };

  /**
   * Renders a template.  If no template is specified, it is assumed that the
   * template matches the request path.
   */
  void render(SpokesRequest request, [Map params,String template]){

    var path = request.uri.path;
    if(template == null){
      template = templatePath+Platform.pathSeparator+path;
    }else{
      if(new File(template).existsSync() == false){
        template = templatePath+Platform.pathSeparator+template;
      }
    }
    if(template.indexOf(".") < 0){
      template += ".html.lug";
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
      new File(template).readAsLines().then((List<String> lines){
        var imports = [];
        ClassMirror cm = reflectClass(this.runtimeType);
        Map<Uri,LibraryMirror> lms = currentMirrorSystem().libraries;
        lms.forEach((Uri uri,LibraryMirror lm){

          if(lm.declarations.containsValue(cm)){
            imports.add(uri);
          }

        });


        imports.forEach((imprt){
          lines.insert(0, "<%import '$imprt'%>");
        });
        request.renderFunction(lines.join("\n"),path,params).then((msg){
                 _setContentType(request,path);
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
      });


    }
  }

  /**
   * serves the file specified in the fileName parameter.
   */
  void serve(SpokesRequest request,String fileName){
    var path =fileName;

    request.renderFunction = new File(path).openRead().pipe;
    _setContentType(request,path);
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

  /**
   * redirects the request to a different location.  The default status code is a 307 TEMPORARY REDIRECT.
   */
  void redirect(SpokesRequest req,String location,{statusCode: HttpStatus.TEMPORARY_REDIRECT}){
    req.response.headers.set(HttpHeaders.LOCATION,location);
    req.response.statusCode = statusCode;
    req.response.close();
  }

  /**
   * Sends a JSON response to the client.
   */
  void sendJSON(SpokesRequest request,var jsonData){
    if(jsonData is SpokesModel){
      jsonData = jsonData();
    }
    request.response.headers.contentType = _extensions["json"];

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
  
  _setContentType(req,String path){
    var extension = "html";
    if(path.lastIndexOf(".") > 0){
      extension= path.substring(path.lastIndexOf(".")+1);
    }
    if(extension.indexOf(".")>0){
      extension = extension.substring(0,extension.indexOf("."));
    }

      req.response.headers.contentType = _extensions[extension];

  }
}