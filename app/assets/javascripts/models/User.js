'use strict';

angular.module('unshamed.models')
  .factory('User', User);

User.$inject = ['$resource'];
function User($resource) {
  var customActions = {
    sendFriendRequest: {
      method: 'POST',
      params: { verb: 'friend_request' }
    },

    cancelFriendRequest: {
      method: 'POST',
      params: { verb: 'cancel_friend_request' }
    },

    mostRecent: {
      method: 'GET',
      params: { verb: 'most_recent.json' }
    },

    checkUsername: {
      method: 'GET',
      params: { verb: 'check_username' }
    }
  };

  var User = $resource('/api/v1/users/:id/:verb', {
    id: '@id'
  }, customActions);

  User.prototype.strugglesAsText = function() {
    return _.map(this.struggles, function(struggle) {
      return "<span class='imp'>" + struggle + "</span>";
    }).join(', ');
  };

  return User;
};
