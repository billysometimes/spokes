
/**
 * The Spokes Library, providing a server, router, controller, and model
 */

library spokes;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:mirrors';

part 'src/spokesServer.dart';
part 'src/spokesController.dart';
part 'src/spokesRoutes.dart';
part 'src/spokesModel.dart';
part 'src/spokesUrl.dart';
part 'src/spokesRequest.dart';
part 'src/spokesResponse.dart';
part 'src/spokesResource.dart';

class Spokes {
  /**
   * A list of middleware classes
   *
   * These will be run several times throughout a requests life
   */
  List _middleWares = [];

  /**
   *The path to the public directory where static assets can be stored.
   */
  //String PUBLIC_PATH;

  /**
   * The template engine to be used.
   *
   * Currently only lug is supported.
   */
  //var templateEngine;

  /**
   * Provides the routes
   */
  //SpokesRoutes router;

  /**
   * Provides general options to the framework
   */
  //Map spokesOptions;

  /**
   * The port the server will run on.  Default is 3000
   */
  //int port;

  /**
   * The host address.  Defaults to localhost.
   */
  //String host;

  /**
   * Database configuration map.
   */
  //Map<String, Map> db;

  /**
   * Path where html templates are stored.  Default is /templates
   */
  //String templatePath;

  /**
   * The application server.
   */
  //SpokesServer _server;


  /**
   * Starts the server.  A certificate may be passed if
   * the server uses a secure socket.
   */
  serve([String host,int port,String certificateName]) {
    if (certificateName == null) {
      new SpokesServer(host, port)._start().then((HttpServer server){
        print("server started on ${server.address.host}:${server.port}");
        server.listen((HttpRequest req){
          SpokesRequest request = new SpokesRequest(req);
          runZoned((){
            _execMiddleWare(request,0);
          },
          onError: (e, stackTrace){
            _processExceptionMiddleware(request,e,0);
            request.response.write('$e $stackTrace');
            request.response.close();
          });

        });
      });
    }
    else
      return new SpokesServer(host, port)._startSecure(certificateName);
  }

  void add(_obj){
    if(_obj is List){
      _middleWares.addAll(_obj);
    }else{
      _middleWares.add(_obj);
    }
  }

  _execMiddleWare(SpokesRequest request,int mw) {
    if(!request.response.isDone){
      if(mw < _middleWares.length){
        try{
          var v = _middleWares[mw].processRequest(request);
          if(v is Future){
            v.then((req){
              _execMiddleWare(req,++mw);
            });
          }else{
            _execMiddleWare(request,++mw);
          }
        }on NoSuchMethodError{
          _execMiddleWare(request,++mw);
        }
      }else{
        //TODO process middleware response in reverse.
      }
    }
  }

  _processExceptionMiddleware(request,error,mw){
    if(!request.response.isDone){
      if(mw < _middleWares.length){
        try{
          var v = _middleWares[mw].processException(request,error);
          if(v is Future){
            v.then((req){
              _processExceptionMiddleware(req,error,++mw);
            });
          }else{
            _processExceptionMiddleware(request,error,++mw);
          }
        }on NoSuchMethodError{
          _processExceptionMiddleware(request,error,++mw);
        }
      }
    }
  }

}