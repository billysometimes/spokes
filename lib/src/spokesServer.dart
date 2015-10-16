/**
 * The server class for the spokes framework.
 */
part of spokes;

class SpokesServer{
  String _host = "127.0.0.1";
  int _port    = 3000;

  SpokesServer([String host,int port]){
    _host = host ?? _host;
    _port = port ?? _port;
  }

  Future<HttpServer> _start(){
    return HttpServer.bind(_host, _port).then((HttpServer server){
      return server;
    });
  }

  Future<HttpServer> _startSecure(certificateName){
    HttpServer.bindSecure(_host, _port, certificateName: certificateName).then((HttpServer server){
      return server;
    });
  }
}

