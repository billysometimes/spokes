/**
import 'packages:spokes/spokes.dart' as Spokes;
export 'packages:spokes/spokes.dart' show SpokesModel, SpokesController, SpokesRoutes, SpokesUrl, SpokesRequest;

export 'dart:io';

import '../settings.dart';
export '../settings.dart';

main(List port){
  if(port.isNotEmpty){
    Spokes.port = int.parse(port[0]);
  }
  Spokes.middleWares = middleWares;
  Spokes.BASE_PATH = BASE_PATH;
  Spokes.PUBLIC_PATH = PUBLIC_PATH;
  Spokes.templateEngine = templateEngine;
  Spokes.start(certificateName);
  Spokes.spokesOptions = spokesOptions;
}
**/