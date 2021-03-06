/**
import 'package:spokes/spokes.dart' as spokes;
export 'package:spokes/spokes.dart'show SpokesModel, SpokesController, SpokesRoutes, SpokesUrl, SpokesRequest, SpokesResource;

import 'dart:io';

import 'dart:async';
import '../settings.dart';

main(List p){
  if(p.isNotEmpty){
    spokes.port = int.parse(p[0]);
    spokes.host = p[1];
  }

  Directory scripts = new Directory(PUBLIC_PATH);

  //compile javascript at runtime
  List initialScripts = scripts.listSync(recursive:true);
  initialScripts.forEach((data){
    if(data.path.indexOf(".dart") > 0 && data.path.indexOf(".js") < 0 && data.path.indexOf("packages") < 0){
      print("compiling for ${data.path}");
      //recompile
      Process.run(spokesOptions["dart2js"], ["-o",data.path+".js",data.path]).then((result){
        if(result.exitCode == 0){
          print("${data.path} successfully compiled to javascript");
          return true;
        }else{
          print("error compiling ${data.path} to js");
        }
      });
    }
  });

  spokes.middleWares = middleWares;
  spokes.PUBLIC_PATH = PUBLIC_PATH;
  spokes.router = router;
  spokes.templateEngine = templateEngine;
  spokes.db = db;
  print("starting server");
  spokes.start(certificateName);
  spokes.spokesOptions = spokesOptions;
  spokes.templatePath = templatePath;


  Stream scriptStream = scripts.watch(recursive:true);

  scriptStream.listen((data){
    if(data.isDirectory == false && (data.type == 2)){
      //file was created or modified
      if(data.path.indexOf(".dart") > 0 && data.path.indexOf(".js") < 0 ){
        print("compiling for ${data.path}");
        //recompile
        Process.run(spokesOptions["dart2js"], ["-o",data.path+".js",data.path]).then((result){
          if(result.exitCode == 0){
            print("${data.path} successfully compiled to javascript");
            return true;
          }else{
            print("error compiling ${data.path} to js");
          }
        });
      }
    }else if(data.type == 4 && data.path.indexOf(".dart") > 0 && data.path.indexOf(".js") < 0){
      //file was deleted
      File js = new File(data.path+".js");
      if(js.existsSync()){
        js.delete();
      }
      File deps = new File(data.path+".js.deps");
      if(js.existsSync()){
        deps.delete();
      }
      File map = new File(data.path+".js.map");
      if(map.existsSync()){
        map.delete();
      }
      File precomiled = new File(data.path+".precompiled.js");
      if(precomiled.existsSync()){
        precomiled.delete();
      }
    }
  });


}
**/