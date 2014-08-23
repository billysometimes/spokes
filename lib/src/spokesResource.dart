part of spokes;

class SpokesResource{
  var _index;
  var _getNew;
  var _post;
  var _getId;
  var _getEdit;
  var _put;
  var _delete;
  
  /**
   * Creates a resource with the following rails routing conventions
   * 
   * **NOTE:** the exception is the GET /controller/new route is mapped to controller => add
   * because 'new' is a Dart reserved keyword.
   */
  SpokesResource({index:"index",add:"add",create:"create",show:"show",edit:"edit",update:"update",destroy:"destroy"}){
    _index = index;
    _getNew = add;
    _post = create;
    _getId = show;
    _getEdit = edit;
    _put = update;
    _delete = destroy;
  }
  
  _buildResource(Object cls){
    return {
      new SpokesUrl("GET","/${cls}") : {"controller":cls,"action":_index},
      new SpokesUrl("GET","/${cls}/new") : {"controller":cls,"action":_getNew}, 
      new SpokesUrl("POST","/${cls}") : {"controller":cls,"action":_post},
      new SpokesUrl("GET","/${cls}/:id") : {"controller":cls,"action":_getId},
      new SpokesUrl("GET","/${cls}/:id/edit") : {"controller":cls,"action":_getEdit},
      new SpokesUrl(["PATCH","PUT"],"/${cls}/:id") : {"controller":cls,"action":_put},
      new SpokesUrl("DELETE","/${cls}/:id") : {"controller":cls,"action":_delete},
    };
  }
}