'use strict';

angular.module('unshamed')
  .controller('NavigationCtrl', NavigationCtrl);

NavigationCtrl.$inject = ['$rootScope', '$auth', '$state'];
function NavigationCtrl($rootScope, $auth, $state) {
  var vm = this;

  vm.test = "TESTING";

  vm.signOut = function() {
    $auth.signOut().finally(function() {
      $state.go('start');
      vm.user = undefined;
    });
  };

};


