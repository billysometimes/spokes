library SpokesLogger;

import 'dart:io';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

final _auditLogger = new Logger("SpokesLogger");

class SpokesLogger {

  var _env = false;

  SpokesLogger([this._env='development']){
    switch(_env){
      case 'development':
        Logger.root.level = Level.ALL;
        break;
      case 'production':
        Logger.root.level = Level.WARNING;
        break;
      case 'testing':
        Logger.root.level = Level.FINEST;
        break;
      default:
        Logger.root.level = Level.ALL;
    }
    //TODO create if it doesn't exist
    Logger.root.onRecord.listen(new SyncFileLoggingHandler("example/log"+Platform.pathSeparator+"audit.log",transformer: new StringTransformer(messageFormat:"%t %m")));
  }

  processRequest(req){
    if(req is Future){
      Completer c = new Completer();
      req.then((request){
        c.complete(_logRequest(request));
      });
      return c.future;
    }else{
      return _logRequest(req);
    }
  }

  processResponse(request){
    Stream s = new Stream.fromIterable([1,2,3,4,5]);
    Completer c = new Completer();
    s.listen((d){

    },onDone:()=>c.complete(request));
    return c.future;
  }

  processException(request, error){
    _logError(reques,error);
    return request;
  }

  _logRequest(req){
    var msg = "REQUEST: ${req.method} ${req.request.uri.path}";

    _auditLogger.fine(msg);

    if(_env == "development") print(msg);

    return req;
  }

  _logError(req,err){
    var msg = "ERROR: ";
    _auditLogger.severe(msg,err);
  }
}