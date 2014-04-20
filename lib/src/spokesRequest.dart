part of spokes;
class SpokesRequest {
  final HttpRequest request;
  Map params;
  Uri uri;
  SpokesRequest(this.request){
    this.params = new Map.from(this.request.uri.queryParameters);
  }

  setUri(uriPath){
    uri = new Uri(path: uriPath);
  }

  HttpResponse get response => request.response;

}