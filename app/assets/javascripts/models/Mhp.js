'use strict';

angular.module('unshamed.models')
  .factory('Mhp', Mhp);

Mhp.$inject = ['$resource'];
function Mhp($resource) {
  var customActions = {
    mostRecent: {
      method: 'GET',
      params: { verb: 'most_recent.json' }
    }
  };

  var Mhp = $resource('/api/v1/mhps/:id/:verb', {
    id: '@id'
  }, customActions);

  Mhp.prototype.strugglesAsText = function() {
    return _.map(this.struggles, function(struggle) {
      return "<span class='imp'>" + struggle + "</span>";
    }).join(', ');
  };

  return Mhp;
};

