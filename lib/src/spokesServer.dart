part of spokes;

class SpokesServer {
  String _host = "127.0.0.1";
  int _port    = 3000;

  SpokesServer([String host,int port]){
    if(host != null)
      _host = host;
    if(port != null){
      _port = port;
    }
  }

  _start(){
    HttpServer.bind(_host, _port).then((HttpServer server){
        server.listen((HttpRequest request)=>_execMiddleWare(request));
    });
  }

  _startSecure(certificateName){
    HttpServer.bindSecure(_host, _port, certificateName: certificateName).then((HttpServer server){
      server.listen((HttpRequest request)=>_execMiddleWare(request));
    });
  }


  _execMiddleWare(HttpRequest request) {
    middleWares.forEach((e){
      request = e(request);
    });
  }

}

