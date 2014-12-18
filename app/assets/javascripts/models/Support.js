'use strict';

angular.module('unshamed.models')
  .factory('Support', Support);

Support.$inject = ['$resource'];
function Support($resource) {
  var customActions = {
    toggle: {
      method: 'POST',
      params: { verb: 'toggle' }
    }
  };

  var Support = $resource('/api/v1/supports/:id/:verb', {
    id: '@id'
  }, customActions);

  return Support;
};

