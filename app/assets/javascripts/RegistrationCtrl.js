'use strict';

angular.module('unshamed.registration')
  .controller('RegistrationCtrl', RegistrationCtrl);

RegistrationCtrl.$inject = ['$scope', '$state', '$auth'];
function RegistrationCtrl($scope, $state, $auth) {
  var vm = this;

  vm.user = {};
  vm.processing = false;
  vm.successful = false;

  vm.register = function() {
    vm.processing = true;
    vm.alerts = [];
    vm.processing = true;
    vm.regForm.$setPristine();

    $auth.submitRegistration(vm.user)
      .then(function(resp) {
        vm.successful = true;
        vm.processing = false;
        vm.alert = { type: 'success', msg: "Thanks for registering. Please check your email for a confirmation link." }
      })
      .catch(function(resp) {
        vm.successful = false;
        vm.processing = false;
        vm.alert = { type: 'warning', msg: "Please double check your information and try again." }
      });
  };
};

