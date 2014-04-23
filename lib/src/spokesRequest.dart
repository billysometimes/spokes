part of spokes;
class SpokesRequest {
  final HttpRequest _request;
  SpokesResponse response;
  Map params;
  Uri uri;
  SpokesRequest(this._request){
    this.params = new Map.from(this._request.uri.queryParameters);
    uri = new Uri(path:this._request.uri.path);
    response = new SpokesResponse(_request.response);
  }

  setUri(uriPath){
    uri = new Uri(path: uriPath);
  }

  get method => _request.method;

  get request => _request;
}