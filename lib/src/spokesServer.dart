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

  _start(){
    HttpServer.bind(_host, _port).then((HttpServer server){
        print("server started on $_host:$_port");
        server.listen((HttpRequest request)=>_execMiddleWare(new SpokesRequest(request)));
    });
  }

  _startSecure(certificateName){
    HttpServer.bindSecure(_host, _port, certificateName: certificateName).then((HttpServer server){
      server.listen((HttpRequest request)=>_execMiddleWare(new SpokesRequest(request)));
    });
  }


  _execMiddleWare(SpokesRequest request) {

    for(final e in middleWares){
      if(!request.response.isDone){
        try{
          e.processRequest(request);
        }on NoSuchMethodError{
          //do nothing
        }catch(error){
          print(error);
        }
      }
    }

    if(!request.response.isDone)
      router.manage(request);
  }

}

