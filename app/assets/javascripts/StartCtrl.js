'use strict';

angular.module('unshamed.login')
  .controller('StartCtrl', StartCtrl);

StartCtrl.$inject = ['$auth', '$state'];
function StartCtrl($auth, $state) {
  var vm = this;

  if ($auth.user) {
    $state.go('home');
  }
};
