/**
 * Class that defines urls to match to routes.
 */

part of spokes;

class SpokesUrl {

  List _methods = new List();
  Uri _uri;

  /**
   * creates a new url with the method or methds provided, and a string representing the uri.
   */
  SpokesUrl(var methods,String uriString){
    _uri = new Uri(path: uriString);
    if(methods is String){
      this._methods.add(methods);
    }else
      this._methods.addAll(methods);
  }
  
  /**
   * Returns the methods defined for this url.
   */
  List get methods => _methods;
  
  /**
   * Returns the uri this SpokesUrl represents.
   */
  Uri get uri => _uri;
}
