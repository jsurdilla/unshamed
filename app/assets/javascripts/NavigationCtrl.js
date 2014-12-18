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

};
