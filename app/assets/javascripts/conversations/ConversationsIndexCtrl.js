'use strict';

angular.module('unshamed')
  .controller('ConversationsIndexCtrl', ConversationsIndexCtrl);

ConversationsIndexCtrl.$inject = ['$scope', '$state', 'convoSvc'];
function ConversationsIndexCtrl($scope, $state, convoSvc) {
  var vm = this;
  vm.conversations = convoSvc.convos;
};
