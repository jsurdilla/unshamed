'use strict';

angular.module('unshamed.login')
  .controller('MemberDetailsCtrl', MemberDetailsCtrl);

MemberDetailsCtrl.$inject = ['$auth', '$scope', '$state', 'User', 'friendRequestSvc', 'FriendshipRequest', 'Friendship', 'member', 'pusherHelperSvc'];
function MemberDetailsCtrl($auth, $scope, $state, User, friendRequestSvc, FriendshipRequest, Friendship, member, pusherHelperSvc) {
  var vm = this;

  if (member.user.is_mhp) {
    vm.templateUrl = 'members/mhp.html'
  } else {
    vm.templateUrl = 'members/member.html'
  }

  // PUBLIC

  vm.sendFriendRequest = function() {
    FriendshipRequest.save({ userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.has_pending_friend_request_to = true;
    });
  };


  // PRIVATE

  $scope.$on('friendship.acceptedReq', function(event, userId) {
    if (vm.user.id === userId) {
      vm.user.has_pending_friend_request_from = false;
      vm.user.is_friend = true;
    }
  });

  $scope.$on('friendship.rejectedReq', function(event, userId) {
    if (vm.user.id === userId) {
      vm.user.has_pending_friend_request_from = false;
    }
  });

  $scope.$on('friendship.unfriended', function(event, userId) {
    if (vm.user.id === userId) {
      vm.user.is_friend = false;
    }
  });

  $scope.$on('friendship.cancelledReq', function(event, userId) {
    if (vm.user.id === userId) {
      vm.user.has_pending_friend_request_to = false;
    }
  });

  pusherHelperSvc.subscribeToNewFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.user.id) {
      vm.user.has_pending_friend_request_from = true;
    }
    $scope.$digest();
  });

  pusherHelperSvc.subscribeToCancelledFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.user_id) {
      vm.user.has_pending_friend_request_from = false;
    }
    $scope.$digest();
  });

  pusherHelperSvc.subscribeToAcceptedFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.receiver_id) {
      vm.user.has_pending_friend_request_to = false;
      vm.user.is_friend = true;
    }
    $scope.$digest();
  });

  pusherHelperSvc.subscribeToRejectedFriendReq(function(data) {
    var fr = data.friendship_request;
    if (vm.user.id === fr.receiver_id) {
      vm.user.has_pending_friend_request_to = false;
    }
  });

  pusherHelperSvc.subscribeToUnfriend(function(data) {
    var exFriend = data.user;
    if (vm.user.id === exFriend.id) {
      vm.user.is_friend = false;
    }
  });

  member.$promise.then(function(data) {
    vm.user = new User(data.user);
  }, null);
};
