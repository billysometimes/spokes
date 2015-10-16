
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
   * Starts the server.  A certificate may be passed if
   * the server uses a secure socket.
   */
  serve([String host,int port,String certificateName]) {
    Future<HttpServer> server;
    if (certificateName == null) {
      server = new SpokesServer(host, port)._start();
    }
    else
      server = new SpokesServer(host, port)._startSecure(certificateName);
    _listenTo(server);
  }

  _listenTo(Future<HttpServer> server){
    server.then((HttpServer server){
      print("server started on ${server.address.host}:${server.port}");
      server.listen((HttpRequest req){
        SpokesRequest request = new SpokesRequest(req);
        runZoned((){
          _execMiddleWare(request,_middleWares.iterator);
        },
        onError: (e, stackTrace){
          _processExceptionMiddleware(request,e,0);
          request.response.write('$e $stackTrace');
          request.response.close();
        });
      });
    });
  }

  /**
   * Adds middleware to the application.
   */
  void add(_obj){
    if(_obj is List){
      _middleWares.addAll(_obj);
    }else{
      _middleWares.add(_obj);
    }
  }

  _execMiddleWare(SpokesRequest request,Iterator itr) {
    if(!request.response.isDone){
      if(itr.moveNext()){
        try{
          var v = itr.current.processRequest(request);
          if(v is Future){
            v.then((req){
              _execMiddleWare(req,itr);
            });
          }else{
            _execMiddleWare(request,itr);
          }
        }on NoSuchMethodError{
          _execMiddleWare(request,itr);
        }
      }else{
        _execResponseMiddleWare(request,_middleWares.reversed.iterator);
      }
    }
  }

  _execResponseMiddleWare(SpokesRequest request,Iterator itr){
    if(!request.response.isDone) {
      if (itr.moveNext()) {
        try {
          var v = itr.current.processResponse(request);
          if (v is Future) {
            v.then((req) {
              _execResponseMiddleWare(req, itr);
            });
          } else {
            _execResponseMiddleWare(request, itr);
          }
        } on NoSuchMethodError {
          _execResponseMiddleWare(request, itr);
        }
      }else{
        request.response.close();
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