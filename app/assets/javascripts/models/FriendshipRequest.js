'use strict';

angular.module('unshamed.models')
  .factory('FriendshipRequest', FriendshipRequest);

FriendshipRequest.$inject = ['$resource'];
function FriendshipRequest($resource) {
  var customActions = {
    query: {
      method: 'GET',
      isArray: false
    },

    accept: {
      method: 'POST',
      isArray: false,
      params: {
        verb: 'accept'
      }
    },

    reject: {
      method: 'POST',
      isArray: false,
      params: {
        verb: 'reject'
      }
    }
  };

  var FriendshipRequest = $resource('/api/v1/users/:user_id/friendship_requests/:id/:verb', {
    user_id: '@userId',
    id: '@id'
  }, customActions);

  return FriendshipRequest;
};

