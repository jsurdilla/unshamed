'use strict';

angular.module('unshamed.login')
  .controller('ConversationsIndexCtrl', ConversationsIndexCtrl)
  .controller('ConversationsInboxCtrl', ConversationsInboxCtrl)
  .controller('ConversationsSentboxCtrl', ConversationsSentboxCtrl)
  .controller('ConversationsShowCtrl', ConversationsShowCtrl);

ConversationsIndexCtrl.$inject = ['$state'];
function ConversationsIndexCtrl($state) {
  var vm = this;

  vm.newMessage = function() {
  };

};

ConversationsInboxCtrl.$inject = ['$state', 'Conversation'];
function ConversationsInboxCtrl($state, Conversation) {
  var vm = this;

  Conversation.inbox({}).$promise.then(function(data) {
    vm.convos = data.conversations;
  });

  vm.showConvo = function(convo) {
    $state.go('convos.inbox.show', { id: convo.id });
  };
};

ConversationsSentboxCtrl.$inject = ['$state', 'Conversation'];
function ConversationsSentboxCtrl($state, Conversation) {
  var vm = this;

  Conversation.sentbox({}).$promise.then(function(data) {
    vm.convos = data.conversations;
  });

  vm.showConvo = function(convo) {
    $state.go('convos.sentbox.show', { id: convo.id });
  };
};


ConversationsShowCtrl.$inject = ['$scope', 'Conversation', 'convo'];
function ConversationsShowCtrl($scope, Conversation, convo) {
  var vm = this;

  vm.reply = { body: '' };

  vm.postReply = function() {
    vm.processing = true;
    Conversation.reply({ id: vm.convo.id, body: vm.reply.body }).$promise.then(function(data) {
      vm.convo.messages.push(data.message);
      vm.reply.body = '';
      vm.processing = false;
    });
  };

  vm.canPostReply = function() {
    return vm.replyForm.$valid && !vm.processing;
  };

  if (convo) {
    convo.$promise.then(function(data) {
      vm.convo = data.conversation;
    }, null);
  }
};

