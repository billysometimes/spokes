/**
 * The server class for the spokes framework.
 */
part of spokes;

class SpokesServer{
  String _host = "127.0.0.1";
  int _port    = 3000;

  SpokesServer([String host,int port]){
    if(host != null)
      _host = host;
    if(port != null){
      _port = port;
    }
  }

  Future<HttpServer>_start(){
    return HttpServer.bind(_host, _port).then((HttpServer server){
      return server;
    });
  }

  _startSecure(certificateName){
    HttpServer.bindSecure(_host, _port, certificateName: certificateName).then((HttpServer server){
      server.listen((HttpRequest request)=>_execMiddleWare(new SpokesRequest(request),0));
    });
  }




}

