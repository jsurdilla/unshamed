'use strict';

angular.module('unshamed.login')
  .controller('MemberDetailsCtrl', MemberDetailsCtrl);

MemberDetailsCtrl.$inject = ['$auth', '$state', 'User', 'FriendshipRequest', 'Friendship', 'member', 'timeline'];
function MemberDetailsCtrl($auth, $state, User, FriendshipRequest, Friendship, member, timeline) {
  var vm = this;

  timeline.$promise.then(function(data) {
    vm.items = data.items;
  }, null);

  member.$promise.then(function(data) {
    vm.user = new User(data.user);
  }, null);

  vm.sendFriendRequest = function() {
    FriendshipRequest.save({ userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.has_pending_friend_request = true;
    });
  };

  vm.cancelFriendRequest = function() {
    FriendshipRequest.delete({}, { userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.has_pending_friend_request = false;
    });
  };

  vm.unfriend = function() {
    Friendship.delete({}, { userId: vm.user.id }).$promise.then(function(data, headers) {
      vm.user.is_friend = false;
    });
  };

};
