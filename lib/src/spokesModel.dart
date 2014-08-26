/**
 * Class that maps data objects to Dart objects for processing.
 */

part of spokes;
class SpokesModel{

  Map _modelMap = {};
  
  /**
   * Defines whether or not all model attributes must be defined or if model
   * attributes can be dynamically added.  
   * 
   * **NOTE:** If you are using a relational database, 
   * it is recommended that strict be set to **true**
   * 
   */
  bool strict = false;
  
  /**
   * A map of all fields for this object.
   */
  final Map fields = {};
  Type _queryType;
  var _db;
  
  /**
   * Can be used to set a non-default database.
   * 
   */
  var use = null;
  
  
   /**
    * Sets the database for the model according to the one provided
    * in the model instance, or the default database defined in settings.dart.
    */
   SpokesModel(){
     //select the database
     var database;
     if(use != null){
       database = use;
     }else if(db[this.runtimeType.toString()] != null){
       print("we hit this one!");
       database = this.runtimeType.toString();
     }else{
       database = "default";
     }
     
     //get instance of database
     ClassMirror dbInstance = reflectClass(db[database]["engine"]);
      _db = dbInstance.newInstance(new Symbol(""), [db[database]]).reflectee;
      _db.set(reflectClass(this.runtimeType).reflectedType.toString()+"s");
     _queryType = this.runtimeType;

     //populate the model map
     this.fields.forEach((key,val){
       if(val is Map){
         if(val.containsKey("default")){
           _modelMap[key] = val["default"];
         }else{
           _modelMap[key] = null;
         }
       }else{
         _modelMap[key] = null;
       }
     });
   }

  void _setField(name,tmp){
    var assignableName = name;
    var arg = tmp;
    if(this.strict){
      if(!hasField(assignableName)){
         throw new Exception("Field $name does not exist for Model ${this.runtimeType}");
      }
    }
    if(fields[assignableName] != null && fields[assignableName].containsKey("type")){

      Type fieldType =  fields[assignableName]["type"];
      if(arg.runtimeType == fieldType){
         _modelMap[name] = arg;
      }else{
         throw new Exception("Field $assignableName requires type $fieldType but got ${arg.runtimeType}");
      }
    }else{
       _modelMap[name] = arg;
    }
  }

  noSuchMethod(Invocation invocation) {
      Symbol methodName = invocation.memberName;
      List tmp = invocation.positionalArguments;

      String name = MirrorSystem.getName(methodName);

      if(name[name.length-1] == "=" ){
        var arg = tmp.length == 1 ? tmp.first : tmp;
        _setField(name.substring(0,name.length-1),arg);
      }else{
        return(_modelMap[name]);
      }
  }
  /**
   * Checks if the object has a given field.
   * 
   *      user.hasField('name');
   */
  bool hasField(Object field){
    return _modelMap.containsKey(field);
  }

  /**
   * Checks if the object has all of the given fields.
   * 
   *       user.hasFields(['name','age','location']);
   */
  bool hasFields(List fields){
    var returnVal=true;
    fields.forEach((field){
      if(!this.hasField(field))
        returnVal= false;
    });
    return returnVal;
  }

  String toString(){
    return _modelMap.toString();
  }

  /**
   * Returns a [Map] representation of this object.
   */
  Map call(){
    return _modelMap;
  }

  get _conn =>  _db.connect().then((conn){return conn;});

  /**
   * Sets the attributes of this model from a map
   * 
   *        new User().from({"last_name":"Smith","first_name":"Sally"});
   *      
   */
  void from(Map m){
      m.forEach((key,val){
        _setField(key,val);
      });
  }

  SpokesModel save(){
    //TODO beforesave callbacks
    _db.save(this());
    return this;
  }

  /**
   * removes this object from the database
   * returns the item removed.
   * 
   *      removeItem(SpokesRequest request){
   *        new Post().get(4).destroy().then((destroyed){
   *          print("removed post ${destroyed['id']}");
   *        });
   *      }
   */
  SpokesModel destroy(){
    _db.destroy();
    return this;
  }

  /**
   *   Returns only the given field for the object.
   *       posts.all().pluck('title');
   */
  SpokesModel pluck(var field){
    _queryType = String;
    return this;
  }

  /**
   * Returns all data objects of the model instance type.
   * 
   *     function getAllUsers(SpokesRequest request){
   *       new User().all().then((allUsers){
   *         render(request,allUsers);
   *       });
   *     }
   */
  SpokesModel all(){
    _db.all();
    _queryType = this.runtimeType;
    return this;
  }

  /**
   * Finds a single object in the database by the models primary key
   * 
   *      findItemTwo(SpokesRequest request){
   *        new Inventory().find(2).then((item){
   *          print("The item with id=2 is ${item['name']}");
   *        });
   *      }
   */
  SpokesModel find(var id){
    _db.find(id);

    _queryType = this.runtimeType;
    return this;
  }

  
  /**
   * Finds all objects in the database with a field matching the attrs given.
   * 
   *      findSmiths(SpokesRequest request){
   *        new User().findBy({"last_name":"Smith"}).then((smiths){
   *          print("Users named smith: ");
   *          smiths.forEach((smith){
   *            print(smith['first_name']);
   *          });
   *        });
   *      }
   */
  SpokesModel findBy(Map attrs){
    _db.findBy(attrs);
    _queryType = this.runtimeType;
    return this;
  }

  /**
   * Finds the first object in the database matching the attrs given.
   * 
   *      findFirstSmith(SpokesRequest request){
   *        new User().findFirstBy({"last_name":"Smith"}).then((smith){
   *          print("The first smith is: ${smith['first_name']}");
   *        });
   *      }
   */
  SpokesModel findFirstBy(Map attrs){
    _db.findFirstBy(attrs);
    _queryType = this.runtimeType;

    return this;
  }

  /**
   * Orders the objects returned on a given field.  "asc" or "desc" can be 
   * specified.  Default is "asc".
   * 
   *     new User().all().orderBy("age","desc");
   */
  SpokesModel orderBy(var field,[var dir = "asc"]){
    _db.orderBy(field,dir);
    return this;
  }

  /**
   * Limits the number of objects returned from the database
   * 
   *      new User().all().limit(10);
   */
  SpokesModel limit(int lim){
    _db.limit(lim);
    return this;
  }

  /**
   * Runs a raw database query.  This is pretty unsafe.
   */
  raw(){
    return _db.raw();
  }

  /**
   * runs the current query and once it is complete it executes the callback.
   * 
   *      Users.all().then((allusers){
   *        print(allusers);
   *      });
   */
  void then(Function callback){
    _conn.then((connection){
      _db.run(connection).then((response){
        var res = [];
        InstanceMirror im = reflect(this);
         ClassMirror cm = im.type;
         if(cm.reflectedType == _queryType){
           if(response is List){
           response.forEach((e){
             var obj = cm.newInstance(new Symbol(""),[]).reflectee;
             try{
               obj.from(e);
               res.add(obj);
             }catch(error){
               res = error;
             }
           });
           res = res.length == 1 ? res[0] : res;
           callback(res);

           }else if(response is Map){
             var obj = cm.newInstance(new Symbol(""),[]).reflectee;

             try{
               obj.from(response);
               res = obj;
             }catch(error){
               res = error;
             }

             callback(res);

           }else{

             //we got a cursor

             response.toArray().then((ar){

               ar.forEach((e){

               var obj = cm.newInstance(new Symbol(""),[]).reflectee;
               try{
                 obj.from(e);
                   res.add(obj);
                 }catch(error){
                   res = error;
               }
               });
               callback(res);
             });
           }
         }else{
           res = response;
           callback(res);

         }
      }).catchError((Exception e){
        print("${e.runtimeType}: $e");
        callback(null);
      });
  });
  }

}