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
part 'src/field.dart';

  List middleWares;
  String BASE_PATH;
  Map templateOptions;
  String PUBLIC_PATH;
  var templateEngine;
  SpokesRoutes router;
  Map spokesOptions;
  int port;
  String host;
  var db;
  String templatePath;
  SpokesServer _server;

  start([String certificateName]){
    _server = new SpokesServer(host,port);
    if(certificateName == null)
      return _server._start();
    else
      return _server._startSecure(certificateName);
  }

