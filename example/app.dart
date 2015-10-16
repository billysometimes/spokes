import 'package:spokes/spokes.dart';
import 'logger.dart';
import 'dart:async';

main(){

  //get a server;
  Spokes app = new Spokes();

  SpokesRouter router = new SpokesRouter();

  router.addRoute("GET",'/home/:id',(request)=>new HomeController().root(request));

  app.add(new SpokesLogger());
  app.add(router);
  app.serve();


}



class HomeController extends SpokesController {

  var _int = 0;

  root(SpokesRequest request) {
    Completer c = new Completer();
    Stream s = new Stream.fromIterable([1,2,3,4,5]);
    s.listen((d){},onDone:(){c.complete(sendJSON(request, {"this":"is my data", "id":request.params['id']}));});
    return c.future;
  }
}