'use strict';

angular.module('unshamed.login')
  .controller('MemberDetailsCtrl', MemberDetailsCtrl);

MemberDetailsCtrl.$inject = ['$auth', '$state', 'User', 'FriendshipRequest', 'Friendship', 'member', 'timeline', 'pusherHelperSvc'];
function MemberDetailsCtrl($auth, $state, User, FriendshipRequest, Friendship, member, timeline, pusherHelperSvc) {
  var vm = this;

  // PUBLIC

  vm.sendFriendRequest = function() {
    FriendshipRequest.save({ userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.has_pending_friend_request_to = true;
    });
  };

  vm.cancelFriendRequest = function() {
    FriendshipRequest.delete({}, { userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.has_pending_friend_request_to = false;
    });
  };

  vm.unfriend = function() {
    Friendship.delete({}, { userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.is_friend = false;
    });
  };

  vm.accept = function() {
    console.log('ACCEPT');
    FriendshipRequest.accept({}, { userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.has_pending_friend_request_from = false;
      vm.user.is_friend = true;
    });
  };

  vm.reject = function() {
    console.log('REJECT');
    FriendshipRequest.reject({}, { userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.has_pending_friend_request_from = false;
    });
  };


  // PRIVATE

  pusherHelperSvc.subscribeToNewFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.user_id) {
      vm.user.has_pending_friend_request_from = true;
    }
  });

  pusherHelperSvc.subscribeToCancelledFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.user_id) {
      vm.user.has_pending_friend_request_from = false;
    }
  });

  pusherHelperSvc.subscribeToAcceptedFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.receiver_id) {
      vm.user.has_pending_friend_request_to = false;
      vm.user.is_friend = true;
    }
  });

  pusherHelperSvc.subscribeToRejectedFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.receiver_id) {
      vm.user.has_pending_friend_request_to = false;
    }
  });

  timeline.$promise.then(function(data) {
    vm.items = data.items;
  }, null);

  member.$promise.then(function(data) {
    vm.user = new User(data.user);
  }, null);
};
