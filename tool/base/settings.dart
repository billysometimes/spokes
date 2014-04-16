/**
library ##;

import 'dart:io';
import 'bin/spokes.dart';

//add middlewares here
import 'middleware/logging.dart';

//add your database
import 'package:rethinkdb_driver/rethinkdb_driver.dart';

//add template engine
import 'package:lug/lug.dart';

//import your apps

part 'routes.dart';

    String BASE_PATH = Platform.pathSeparator + Platform.script.pathSegments.sublist(0, Platform.script.pathSegments.length-2).join(Platform.pathSeparator);

    Map _templateOptions = {"templatePath": BASE_PATH+"/templates/",     //where templates are stored
                          "debug"       : true,                          //debug stuff
                          "cache"       : false,                         //whether or not hub should cache files
                          "cachePath"   : BASE_PATH+"/cache",            //relative path the cache uses
                        };

    String PUBLIC_PATH = BASE_PATH + "/public";

    //middlewares
    List middleWares = [new Logger().log,new Routes().manage];

    var templateEngine = new Lug(_templateOptions);

    String certificateName = null;

    Routes router = new Routes();

    Map spokesOptions = {"recompileDartFiles":false,
                         "dart2js":Platform.executable+Platform.pathSeparator+'dart2js',"env":"development",
                         "packages":Directory.current.path+Platform.pathSeparator+"packages"};


    Rethinkdb db = new Rethinkdb();
**/