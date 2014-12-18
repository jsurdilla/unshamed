'use strict';

angular.module('unshamed.models')
  .factory('Me', Me);

Me.$inject = ['$resource'];
function Me($resource) {
  var customActions = {
    timeline: {
      method: 'GET',
      params: { verb: 'timeline' }
    }
  }

  var Me = $resource('/api/v1/me/:verb', {
    userID: '@userID'
  }, customActions);

  return Me;
};

