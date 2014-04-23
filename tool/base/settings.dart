/**
library ##;


import 'dart:io';
import 'bin/spokes.dart';

//add middlewares here
import 'middleware/logging.dart';

//add your database
import 'package:rethinkdb_driver/rethinkdb_driver.dart';

//add template engine
import '../../dart/lug/lib/lug.dart';

//import your apps
import 'chatApp/chatApp.dart';

part 'routes.dart';

    String BASE_PATH = Directory.current.path + Platform.pathSeparator;

    Map _templateOptions = {"templatePath": "templates/",     //where templates are stored
                          "debug"       : true,                          //debug stuff
                          "cache"       : false,                         //whether or not hub should cache files
                          "cachePath"   : BASE_PATH+"/cache",            //relative path the cache uses
                        };

    String PUBLIC_PATH = "public/";

    //middlewares
    List middleWares = [new SpokesLogger(spokesOptions["env"])];

    //default template engine
    var templateEngine = new Lug(_templateOptions);

    String certificateName = null;

    //general options
    Map spokesOptions = {
                         "dart2js":'dart2js',"env":"development",
                         "packages":"packages"
                        };

    SpokesRoutes router = new Routes();

    //database config
    Rethinkdb db = new Rethinkdb();
**/