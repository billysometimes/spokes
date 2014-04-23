/**
library SpokesLogger;

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

final _auditLogger = new Logger("SpokesLogger");
class SpokesLogger {
  var _env = false;
  SpokesLogger(this._env){
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
    Logger.root.onRecord.listen(new SyncFileLoggingHandler("log"+Platform.pathSeparator+"audit.log",transformer: new StringTransformer(messageFormat:"%t %m")));
  }
  processRequest(req){
    var msg = "REQUEST: ${req.method} ${req.request.uri.path}";
    _auditLogger.fine(msg);
    if(_env == "development") print(msg);
    return req;
  }
}
**/