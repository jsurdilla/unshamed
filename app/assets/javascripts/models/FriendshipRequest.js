'use strict';

angular.module('unshamed.models')
  .factory('FriendshipRequest', FriendshipRequest);

FriendshipRequest.$inject = ['$resource'];
function FriendshipRequest($resource) {
  var customActions = {
  };

  var FriendshipRequest = $resource('/api/v1/users/:user_id/friendship_requests/:id/:verb', {
    user_id: '@userId',
    id: '@id'
  }, customActions);

  return FriendshipRequest;
};

