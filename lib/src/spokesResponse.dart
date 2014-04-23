part of spokes;

class SpokesResponse implements IOSink{
  HttpResponse _response;
  bool isDone = false;
  Encoding encoding;

  SpokesResponse(this._response){
    encoding = _response.encoding;
  }

  close(){
    _response.close();
    isDone = true;
  }

  write(Object obj){
    _response.write(obj);
  }

  get headers => _response.headers;

  flush() => _response.flush;

  addStream(stream) => _response.addStream(stream);

  add(data)=> _response.add(data);

  get done => _response.done;

  set statusCode(code) => _response.statusCode = code;

  writeln([Object obj])=>_response.writeln(obj);

  writeCharCode(int charCode) => _response.writeCharCode(charCode);

  addError(dynamic error, [StackTrace stackTrace]) => _response.addError(error, stackTrace);

  writeAll(Iterable<dynamic> objects, [String separator]) => _response.writeAll(objects,separator);
}