'use strict';

angular.module('unshamed.models')
  .factory('Friendship', Friendship);

Friendship.$inject = ['$resource'];
function Friendship($resource) {
  var customActions = {
  };

  var Friendship = $resource('/api/v1/users/:user_id/friendships/:id/:verb', {
    user_id: '@userId',
    id: '@id'
  }, customActions);

  return Friendship;
};
