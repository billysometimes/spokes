part of spokes;
class SpokesModel{

  Map _modelMap = {};
  var id;
  bool strict = false;
  final Map fields = {};
  Type _queryType;
  var _db;
  var use = null;
   SpokesModel(){
     var database = use == null ? "default" : use;
     ClassMirror dbInstance = reflectClass(db[database]["engine"]);
      _db = dbInstance.newInstance(new Symbol(""), [db[database]]).reflectee;
      _db.set(reflectClass(this.runtimeType).reflectedType.toString()+"s");
     _queryType = this.runtimeType;

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

  _setField(name,tmp){
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

  hasField(Object field){
    return _modelMap.containsKey(field);
  }

  hasFields(List fields){
    var returnVal=true;
    fields.forEach((field){
      if(!this.hasField(field))
        returnVal= false;
    });
    return returnVal;
  }

  toString(){
    return _modelMap.toString();
  }

  call(){
    return _modelMap;
  }

  get _conn =>  _db.connect().then((conn){return conn;});

  from(Map m){
      m.forEach((key,val){
        _setField(key,val);
      });
  }

  save(){
    //TODO beforesave callbacks
    _db.save(this());
    return this;
  }

  destroy(){
    _db.destroy();
    return this;
  }

  pluck(var field){
    _queryType = String;
    return this;
  }

  all(){
    _db.all();
    _queryType = this.runtimeType;
    return this;
  }

  find(var id){
    _db.find(id);

    _queryType = this.runtimeType;
    return this;
  }

  findBy(Map attrs){
    _db.findBy(attrs);
    _queryType = this.runtimeType;
    return this;
  }

  findFirstBy(Map attrs){
    _db.findFirstBy(attrs);
    _queryType = this.runtimeType;

    return this;
  }

  orderBy(var field,[var dir = "asc"]){
    _db.orderBy(field,dir);
    return this;
  }

  limit(int lim){
    _db.limit(lim);
    return this;
  }

  raw(){
    return _db.raw();
  }

  then(Function f){
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
           f(res);

           }else if(response is Map){
             var obj = cm.newInstance(new Symbol(""),[]).reflectee;

             try{
               obj.from(response);
               res = obj;
             }catch(error){
               res = error;
             }

             f(res);

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
               f(res);
             });
           }
         }else{
           res = response;
           f(res);

         }
      }).catchError((Exception e){
        print("${e.runtimeType}: $e");
        f(null);
      });
  });
  }

}