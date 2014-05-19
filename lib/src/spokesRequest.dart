part of spokes;
class SpokesRequest {
  final HttpRequest _request;
  SpokesResponse response;
  Map params;
  Uri uri;
  List<Function> beforeFilters =[];
  List<Function> afterFilters = [];

  Function renderFunction;

  SpokesRequest(this._request){
    this.params = new Map.from(this._request.uri.queryParameters);
    uri = new Uri(path:this._request.uri.path);
    response = new SpokesResponse(_request.response);
  }

  setUri(uriPath){
    uri = new Uri(path: uriPath);
  }

  String get method => _request.method;

  HttpRequest get request => _request;

  HttpSession get session => _request.session;

  HttpHeaders get headers => _request.headers;

}