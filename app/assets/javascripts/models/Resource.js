'use strict';

angular.module('unshamed.models')
  .factory('Resource', Resource);

Resource.$inject = ['$resource'];
function Resource($resource) {
  var customActions = {
    query: {
      method: 'GET',
      isArray: false
    }
  };

  var Resource = $resource('/api/v1/resources/:resourceId/:verb', {
    resourceId: '@resourceId'
  }, customActions);

  return Resource;
};
