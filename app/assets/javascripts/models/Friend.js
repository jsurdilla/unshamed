'use strict';

angular.module('unshamed.models')
  .factory('Friend', Friend);

Friend.$inject = ['$resource'];
function Friend($resource) {
  var customActions = {
    query: {
      method: 'GET',
      isArray: false
    }
  };

  var Friend = $resource('/api/v1/friends/:friendID/:verb', {
    friendID: '@friendID'
  }, customActions);

  return Friend;
};

