'use strict';

angular.module('unshamed.login')
  .controller('LoginCtrl', LoginCtrl);

LoginCtrl.$inject = ['$auth', '$state'];
function LoginCtrl($auth, $state) {
  var vm = this;

  vm.user = {};
  vm.processing = false;
  vm.successful = false;

  vm.login = function() {
    vm.processing = true;
    vm.loginForm.$setPristine();

    $auth.submitLogin(vm.user)
      .then(function(resp) {
        vm.successful = true;
        vm.processing = false;
        $state.go('home');
      })
      .catch(function(resp) {
        vm.successful = false;
        vm.processing = false;
        vm.alert = { type: 'warning', msg: "Please double check your information and try again." };
      });
  };
};
