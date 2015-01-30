'use strict';

angular.module('unshamed')
  .controller('NavigationCtrl', NavigationCtrl);

NavigationCtrl.$inject = ['$compile', '$rootScope', '$scope', '$auth', '$state', '$templateCache', '$timeout', 'FriendshipRequest'];
function NavigationCtrl($compile, $rootScope, $scope, $auth, $state, $templateCache,  $timeout,  FriendshipRequest) {
  var vm = this;

  // PUBLIC

  vm.signOut = function() {
    $auth.signOut().finally(function() {
      $state.go('start');
      vm.user = undefined;
    });
  };

  vm.friendRequests = $templateCache.get('friend_requests2.html');

  $scope.accept = function() {
    console.log('accept');
  };

  // PRIVATE

  FriendshipRequest.query({}, { userId: $auth.user.id }).$promise.then(function(data) {
    vm.friendshipRequests = data.friendship_requests;
  });

};
