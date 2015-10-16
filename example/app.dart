import 'package:spokes/spokes.dart';
import 'logger.dart';

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
    sendJSON(request, {"this":"is my data", "id":request.params['id']});
  }
}