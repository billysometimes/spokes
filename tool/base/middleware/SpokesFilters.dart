/**
library SpokesFilters;

class SpokesFilters {

  processRequest(req){

  }

  processController(request,Function controller){

    if(request.beforeFilters.isNotEmpty)
      _filterRequests(request.beforeFilters, request);
  }

  processResponse(request){
    if(request.afterFilters.isNotEmpty)
      _filterRequests(request.afterFilters, request);

  }

  _filterRequests(List filters, var request){

      filters.forEach((filter){
        filter(request);
      });
  }


}
**/