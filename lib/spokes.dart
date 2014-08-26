
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


  /**
   * A list of middleware classes
   *
   * These will be run several times throughout a requests life
   */
  List middleWares;
  
  /**
   *The path to the public directory where static assets can be stored.
   */
  String PUBLIC_PATH;
  
  /**
   * The template engine to be used.  
   * 
   * Currently only lug is supported.
   */
  var templateEngine;
  
  /**
   * Provides the routes
   */
  SpokesRoutes router;
  
  /**
   * Provides general options to the framework 
   */
  Map spokesOptions;
  
  /**
   * The port the server will run on.  Default is 3000
   */
  int port;
  
  /**
   * The host address.  Defaults to localhost.
   */
  String host;
  
  /**
   * Database configuration map.  
   */
  Map<String, Map> db;
  
  /**
   * Path where html templates are stored.  Default is /templates
   */
  String templatePath;
  
  /**
   * The application server.
   */
  SpokesServer _server;

  
  /**
   * Starts the server.  A certificate may be passed if 
   * the server uses a secure socket.
   */
  start([String certificateName]){
    router._init();
    _server = new SpokesServer(host,port);
    if(certificateName == null)
      return _server._start();
    else
      return _server._startSecure(certificateName);
  }

