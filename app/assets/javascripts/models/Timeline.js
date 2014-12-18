'use strict';

angular.module('unshamed.models')
  .factory('Timeline', Timeline);

Timeline.$inject = ['$resource'];
function Timeline($resource) {
  var customActions = {
  };

  var Timeline = $resource('/api/v1/timeline/:verb', {
  }, customActions);

  return Timeline;
};

