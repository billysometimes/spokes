library spokes;

import 'dart:io';
import 'dart:convert';
part 'src/spokesServer.dart';
part 'src/spokesController.dart';
part 'src/spokesRoutes.dart';
part 'src/spokesModel.dart';
part 'src/spokesUrl.dart';
part 'src/spokesRequest.dart';

  List middleWares;
  String BASE_PATH;
  Map templateOptions;
  String PUBLIC_PATH;
  var templateEngine;
  SpokesRoutes router;
  Map spokesOptions;
  int port;

  SpokesServer _server = new SpokesServer(null,port);

  start([String certificateName]){
    if(certificateName == null)
      return _server._start();
    else
      return _server._startSecure(certificateName);
  }
