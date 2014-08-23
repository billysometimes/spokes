part of spokes;

class SpokesResponse implements IOSink{
  HttpResponse _response;
  
  /**
   * Returns true if the response has been closed.
   */
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

  /**
   * Returns the headers associated with the response.
   */
  get headers => _response.headers;

  flush() => _response.flush;

  addStream(stream) => _response.addStream(stream);

  add(data)=> _response.add(data);

  get done => _response.done;

  /**
   * Sets the status code of the response.
   */
  set statusCode(code) => _response.statusCode = code;

  writeln([Object obj])=>_response.writeln(obj);

  writeCharCode(int charCode) => _response.writeCharCode(charCode);

  addError(dynamic error, [StackTrace stackTrace]) => _response.addError(error, stackTrace);

  writeAll(Iterable<dynamic> objects, [String separator]) => _response.writeAll(objects,separator);
}