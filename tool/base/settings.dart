/**
library ##;


import 'dart:io';
import 'dart:async';

import 'bin/spokes.dart';

//add middlewares here
import 'middleware/Logging.dart';

//add your database
import 'etc/rethinkORM.dart';

//add template engine
import 'package:lug/lug.dart';

//import your apps


//include routes
part 'routes.dart';

    /**
     * The directory where static assets are stored, starting from the current directory
     */
    String PUBLIC_PATH = "web";

    /**
     * The directory where lug or mustache templates are stored, starting from the current
     * directory.
     */
    String templatePath = "templates";
    
    
    /**
     * A list of all of the middleware classes that should be run
     */
    List middleWares = [new SpokesLogger(spokesOptions["env"])];
    
    /**
     * The template engine to use.  The default is lug, though mustache can be
     * used as well.
     */
    var templateEngine = new Lug();

    /**
     * If the server is an Https server, provide the name of the certificate to use.
     */
    String certificateName = null;

    /**
     * The router to be used.
     */
    SpokesRoutes router = new Routes();

    /**
     * General spokes options.  Currently the available options are:
     * 
     * dart2js: 
     *   - the path to your dart2js installation for automatic compilation of dart
     * to javascript.
     * 
     * env: 
     *   -acceptable values are 'development','test',and 'production'.
     */
    Map spokesOptions = {
                         //Change to your dart2js executable location
                         "dart2js":"/Applications/dart/dart-sdk/bin/dart2js",
                         "env":"development",
                        };

     /**
     * database config.  Databases can be specified by model. For instance we could have:
     * var db = {
     *            //configure our user database to use
     *            //a mysql database named UserDB
     *            "User":{"engine":SomeMYSQLDB,"name":"UserDB","user":"myDBuser","password":"secretpass","host":"mydbhost","port":27000},
     *     
     *            //configure a default database to a rethinkdb database
     *            //named AppName
     *            "default":{"engine":RethinkORM,"name":"AppName"}
     * }
     */
    Map db = {"default":{"engine":RethinkORM,"name":"test"}};
**/
