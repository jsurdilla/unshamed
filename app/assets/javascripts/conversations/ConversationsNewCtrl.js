'use strict';

angular.module('unshamed.login')
  .controller('ConversationsNewCtrl', ConversationsNewCtrl);

ConversationsNewCtrl.$inject = ['$scope', 'Conversation', '$q', '$state', 'convoSvc'];
function ConversationsNewCtrl($scope, Conversation, $q, $state, convoSvc) {
  var vm = this;
  vm.draft = {};
  vm.sendButtonText = "Send";

  convoSvc.setCurrentConversation(null);

  // PUBLIC

  vm.getRecipients = function($query) {
    var deferred = $q.defer();
    Conversation.recipientAutocomplete().$promise.then(function(data) {
      deferred.resolve(_.map(data.users, function(user) {
        return { user_id: user.id, text: user.full_name }
      }));
    });
    return deferred.promise;
  };

  vm.sendMessage = function() {
    vm.processing = true;
    vm.sendButtonText = "Sending...";
    var user_ids = _.pluck(vm.draft.users, 'user_id');
    Conversation.save({ body: vm.draft.body, user_ids: user_ids }, function(data) {
      var convo = data.conversation;
      console.log(convo);
      vm.processing = false;
      vm.sendButtonText = "Sent";
      convoSvc.prependConvo(convo);
      $state.go('conversations.show', { id: data.conversation.id });
    });
  };
};
