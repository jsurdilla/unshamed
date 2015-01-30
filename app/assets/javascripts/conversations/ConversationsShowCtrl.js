'use strict';

angular.module('unshamed.conversations')
  .directive('conversationList', ['reactDirective', 'ConversationList', function(reactDirective, ConversationList) {
    return reactDirective('ConversationList', ['firstTime', 'conversationId']);
  }])
  .controller('ConversationsShowCtrl', ConversationsShowCtrl);

ConversationsShowCtrl.$inject = ['$scope', 'Conversation', 'convo', '$auth', '$timeout', 'convoSvc', 'pusherHelperSvc'];
function ConversationsShowCtrl($scope, Conversation, convo, $auth, $timeout, convoSvc, pusherHelperSvc) {
  var vm = this;
  vm.convo = convo;

  convoSvc.markAsRead(convo);
  convoSvc.setCurrentConversation(convo);
  convoSvc.toThreadFormat(convo.messages);
  vm.sections = convoSvc.sections;
  $timeout(function () {
    vm.lastMessageAddedAt = new Date();
  }, 500);

  vm.reply = { body: '' };

  vm.postReply = function() {
    vm.processing = true;
    Conversation.reply({ id: vm.convo.id, body: vm.reply.body }).$promise.then(function(data) {
      vm.convo.messages.push(data.message);
      convoSvc.addMessageToThread(data.message);
      vm.reply.body = '';
      vm.processing = false;
      vm.lastMessageAddedAt = data.message.created_at;
    });
  };

  vm.canPostReply = function() {
    return vm.replyForm.$valid && !vm.processing;
  };

  vm.participantsInHeaderFormat = function() {
    var text = _.chain(convo.participants).
      first(2).
      pluck('full_name').
      value().
      join(', ');

    var len = convo.participants.length;
    if (len == 5) {
      text += " + 1 other."
    } else if (len > 3) {
      text += (convo.participants.length - 2) + " others"
    };

    return text;
  };


  // PRIVATE

  var newReplyCallback = function(data) {
    if (vm.convo.id === data.conversation.id) {
      vm.convo.messages.push(data.message);
      convoSvc.addMessageToThread(data.message);
      vm.lastMessageAddedAt = data.message.created_at;
    }
    $scope.$digest(); // necessary
  };

  pusherHelperSvc.subscribeToNewReply(newReplyCallback);

  $scope.$on('$destroy', function() {
    pusherHelperSvc.unsubscribeToNewReply(newReplyCallback);
  });
};


function conversationThreadDataFormatter(messages) {
  console.log(messages);
};


