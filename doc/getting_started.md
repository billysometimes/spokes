Quickstart:

1) Install the latest dart 

2) Download the project

3) add dart to your environment path in ~/.bash_profile or where ever your system prefers:
    export PATH=$PATH:/path/to/dart/bin/
    
4) add spokes to your path in your ~/.bash_profile, or where ever your system prefers:
    export PATH=$PATH:/path/to/spokes/bin/
    
5) from the command line, test spokes:
    $ spokes -v
    
6) create a new project:
    $ spokes new project sampleProject
    $ cd sampleProject
    
7) create a new app:
    $ spokes new app sampleApp
    $ cd sampleApp
    
8) create a controller:
    $ spokes generate controller HomeController
    $ cd ..
    
9) add a url to routes.dart:
    new SpokesUrl("GET",'/') : new HomeController().root
    
10) add a method named root to sampleApp/controllers/HomeController.dart
    root(req){
      serve('/public/index.html');
    }
    
11) create a page to serve at public/index.html:
    <h1>hello, spokes!</h1>
    
12) start spokes:
    $ spokes spin
    
    if you get permissions errors, change the permissions to projectname/bin/spokes.dart
    
13) in your web browser visit localhost:3000


Controllers:

currently controllers have two methods, serve() and render().

the default template engine is lug, written specifically for spokes. This can be changed in settings.dart 

serve() Has one required argument: the requeest, and one optional argument: a path. 
It simply serves the file at the given path.  If no path is provided
spokes attempts to serve the file at the location of the request.

render() Has one required argument: the request and two optional arguments:a map of parameters and a file path.
It renders the lug template located in the /templates folder, passing in the map of parameters.  If a path is not specified 
spokes looks for a template with the same name as the request.


Routes:

  routes.dart maps specific routes to controllers. the [key] in the Map urls
  is a SpokesUrl, which has a method/methods and a url to match.  params can be placed in the url with a colon. Examples:
  
    //route all GET requests to /home/someparam to the HomeControllers method named root
    new SpokesUrl("GET",'/home/:user') : new HomeController().root
    
    //map all GET and POST requests from /signup to the RegistrationControllers method named newUser
    new SpokesUrl(["GET","POST"],'/signup') : new RegistrationController().newUser
    
Models:

  Models can be generated with the command:
    $ spokes generate model UserModel
    
  The default database is rethinkDB.  this can be changed in the settings.dart file, or a second database
  can be added.
  
  methods can be added to the model, that can then be called by the controller. for example:
  
  in projectName/sampleApp/models/User.dart:
  
  part of sampleApp;

  class User extends SpokesModel {

    static Future createUser(Map user){
      //db.connect refers to the database in settings.dart
      return db.connect(db: "test",port: 28015).then((conn){
        return db.table("users").insert(user).run(conn).then((res){
          conn.close();
          return res;
        });
      });
    }
  }
  
  
  and in projectName/sampleApp/controllers/RegistrationController.dart:
  
  part of sampleApp;

  class HomeController extends SpokesController {
    
    createNewUser(request){
      User.createUser(request.param["user"]).then((createdResponse){
        render(request,createdResponse);
      });
    }
  }
  