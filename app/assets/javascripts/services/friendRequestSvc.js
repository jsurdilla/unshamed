'use strict';

angular.module('unshamed.services')
  .service('friendRequestSvc', friendRequestSvc);

friendRequestSvc.$inject = ['$auth', '$rootScope', 'Friendship', 'FriendshipRequest', 'pusherHelperSvc'];
function friendRequestSvc($auth, $rootScope, Friendship, FriendshipRequest, pusherHelperSvc) {
  var self = this;

  self.friendshipRequests = [];

  self.acceptReqFromUser = function(user) {
    var request = FriendshipRequest.accept({}, { userId: user.id });
    request.$promise.then(function(data, headers) {
      var fr = findByUserId(user.id);
      if (fr) {
        fr.state = 'accepted';
      }
      $rootScope.$broadcast('friendship.acceptedReq', user.id);
    });
    return request.$promise;
  };

  self.rejectReqFromUser = function(user) {
    var request = FriendshipRequest.reject({}, { userId: user.id });
    request.$promise.then(function(data, headers) {
      var fr = findByUserId(user.id);
      if (fr) {
        fr.state = 'rejected';
      }
      $rootScope.$broadcast('friendship.rejectedReq', user.id);
    });
    return request.$promise;
  };

  self.cancelReqToUser = function(user) {
    var request = FriendshipRequest.delete({}, { userId: user.id }).$promise.then(function(data, headers) {
      $rootScope.$broadcast('friendship.cancelledReq', user.id);
    });
    return request.$promise;
  };

  self.unfriendUser = function(user) {
    var request = Friendship.delete({}, { userId: user.id });
    request.$promise.then(function(data, headers) {
      $rootScope.$broadcast('friendship.unfriended', user.id);
    });
    return request.$promise;
  };


  // Private

  function findByUserId(userId) {
    return _.find(self.friendshipRequests, function(fr) {
      return fr.user.id === userId;
    });
  };

  // Make sure to wait for a valid user.
  $auth.validateUser().then(function(user) {
    FriendshipRequest.query({}, { userId: $auth.user.id }).$promise.then(function(data) {
      self.friendshipRequests = data.friendship_requests;
    });

    pusherHelperSvc.subscribeToNewFriendReq(function(data) {
      var fr = data.friendship_request;
      var existing = self.friendshipRequests.getIndexBy('id', fr.id) > -1;
      if (!existing) {
        self.friendshipRequests.splice(0, 1, fr);
      }
    });
  });

};
