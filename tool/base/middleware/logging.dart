/**
library Logger;

import 'dart:io';

class Logger {
  log(HttpRequest req){
    print("Middleware logging: ${req.uri.path}");
    return req;
  }
}
**/