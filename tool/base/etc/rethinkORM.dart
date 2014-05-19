/**
library rethinkORM;

import 'package:rethinkdb_driver/rethinkdb_driver.dart';
import 'dart:async';
class RethinkORM {

  var _query;
  var _connection;

  String _db = null;
  String _host = null;
  num _port = null;
  String _authKey = null;

  RethinkORM(Map settings){

    _db = settings["name"] != null ? settings["name"] : "test";
    _host = settings["host"] != null ? settings["host"] : "127.0.0.1";
    _port = settings["port"] != null ? settings["port"] : 28015;
    _authKey = settings["authKey"] != null ? settings["authKey"] : "";
  }

  pluck(var field){
    _query = _query.pluck(field);
    return this;
  }

  all(){
    //_query = table;
  }

  find(var id){
    _query = _query.get(id);
  }

  findBy(Map attrs){
    _query = _query.filter(attrs);
  }

  limit(int lim){
    _query = _query.limit(lim);
  }

  set(String tblName){
    _query = new Rethinkdb().table(tblName);
  }

  save(Map record){
    _query = _query.insert(record,{"upsert":true,"return_vals":true});
  }

  _asc(var field){
    return new Rethinkdb().asc(field);
  }

  _desc(var field){
    return new Rethinkdb().desc(field);
  }

  orderBy(var field, var dir){
    field = dir == "asc" ? _asc(field) : _desc(field);
    _query = _query.orderBy(field);
  }

  destroy(){
    _query = _query.delete({"return_vals":true});
  }

  run(connection){
    Completer c = new Completer();
    _query.run(connection).then((res){
      c.complete(res);
    });
    return c.future;
  }

  raw(){
    return new Rethinkdb();
  }

  connect(){
    Completer c = new Completer();
    new Rethinkdb().connect(db:_db,port:_port,authKey:_authKey,host:_host).then((conn){
      c.complete(conn);
    });
    return c.future;
  }

}
**/