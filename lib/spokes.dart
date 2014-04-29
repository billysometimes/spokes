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
part 'src/spokesFilter.dart';


  List middleWares;
  String BASE_PATH;
  Map templateOptions;
  String PUBLIC_PATH;
  var templateEngine;
  SpokesRoutes router;
  Map spokesOptions;
  int port;
  var db;
  SpokesServer _server;

  start([String certificateName]){
    print("ahem");
    print(router);
    _server = new SpokesServer(null,port);
    if(certificateName == null)
      return _server._start();
    else
      return _server._startSecure(certificateName);
  }

