/**
 * Extends the dart [HttpRequest] class to provide spokes-specific functions.
 */

part of spokes;
class SpokesRequest {
  final HttpRequest _request;
  
  /**
   * The [SpokesResponse] associated with this [SpokesRequest].
   */
  SpokesResponse response;
  
  /**
   * Returns GET and POST parameters for a request, as well as any parameters set
   * from the url.
   */
  Map params;
  
  /**
   * The [Uri] associated with this request.
   */
  Uri uri;

  
  /**
   * The function used to render templates for a request.  The default is [Lug]'s render.
   */
  Function renderFunction;

  SpokesRequest(this._request){
    this.params = new Map.from(this._request.uri.queryParameters);
    uri = new Uri(path:this._request.uri.path);
    response = new SpokesResponse(_request.response);
  }

  /**
   * Sets the uri the the uriPath.
   */
  void setUri(String uriPath){
    uri = new Uri(path: uriPath);
  }

  /**
   * Returns the Http method of the request.
   */
  String get method => _request.method;

  /**
   * Returns the [HttpRequest] that this SpokesRequest extends.
   */
  HttpRequest get request => _request;

  /**
   * The [HttpSession] associated with this request.
   */
  HttpSession get session => _request.session;

  /**
   * Returns the [HttpHeaders] associated with the request.
   */
  HttpHeaders get headers => _request.headers;

}