part of spokes;
class SpokesModel{

  var _obj;
  var _tbl;

  SpokesModel(){
    _tbl = db.table(reflectClass(this.runtimeType).reflectedType.toString());
    _obj = _tbl;
  }

  get(var id){
    return _obj.get(id);
  }

  avg(var field){
    return _obj.avg(field);
  }

  concatMap(Function f){
    return _obj.concatMap(f);
  }

  forEach(Function f){
    return _obj.forEach(f);
  }

  group(var gr){
    return _obj.group(gr);
  }

  innerJoin(var a, var b){
    return _obj.innerJoin(a,b);
  }

  limit(int lim){
    return _obj.limit(lim);
  }

  merge(var obj){
    return _obj.merge(obj);
  }

  orderBy(var order){
    return _obj.orderBy(order);
  }

  reduce(Function func){
    return _obj.reduce(func);
  }

  skip(int index){
    return _obj.skip(index);
  }

  sync(){
    return _obj.sync();
  }

  update(var expr,[Map options]){
    return _obj.update(expr,options);
  }


  filter(var filter){
    return _obj.filter(filter);
  }

  between(var l, var r,[Map options]){
    return _obj.between(l,r,options);
  }

  contains(var val){
    return _obj.contains(val);
  }

  delete([Map options]){
    return _obj.delete(options);
  }

  eqJoin(l,r,[Map index]){
    return _obj.eqJoin(l,r,index);
  }

  hasFields(var fields){
    return _obj.eqJoin(fields);
  }

  get _conn =>  db.connect(db: "test",port: 28015).then((conn){return conn;});

  run(var q){
    Completer c = new Completer();
     _conn.then((connection){
      _obj.run(connection).then((response){
        c.complete(response);
      });
    });
     return c.future;
  }
}