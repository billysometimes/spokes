/**
library ##;


import 'dart:io';
import 'bin/spokes.dart';

//add middlewares here
import 'middleware/Logging.dart';
import 'middleware/SpokesFilters.dart';


//add your database
import 'etc/rethinkORM.dart';

//add template engine
import 'package:lug/lug.dart';

//import your apps

part 'routes.dart';

    String BASE_PATH = Platform.pathSeparator + Platform.script.pathSegments.sublist(0, Platform.script.pathSegments.length-2).join(Platform.pathSeparator);

    Map _templateOptions = {"templatePath": BASE_PATH+"/templates/",     //where templates are stored
                            "debug"       : true,                          //debug stuff
                            "cachePath"   : BASE_PATH+"/cache",            //relative path the cache uses
                            };

    String PUBLIC_PATH = BASE_PATH + "/web";

    //middlewares
    List middleWares = [new SpokesLogger(spokesOptions["env"]), new SpokesFilters()];

    var templateEngine = new Lug(_templateOptions);

    String templatePath = BASE_PATH+Platform.pathSeparator+"templates";

    String certificateName = null;

    Routes router = new Routes();

    Map spokesOptions = {
                         "dart2js":'dart2js',"env":"development",
                         "packages":Directory.current.path+Platform.pathSeparator+"packages"
                        };



    //database config
        var db = {"default":{"engine":RethinkORM,"name":"test"}};
**/
