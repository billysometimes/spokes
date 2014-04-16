part of spokes;

class SpokesUrl {

  List methods = new List();
  Uri uri;

  SpokesUrl(methods,uriString){
    uri = new Uri(path: uriString);
    if(methods is String){
      this.methods.add(methods);
    }else
      this.methods.addAll(methods);
  }
}
