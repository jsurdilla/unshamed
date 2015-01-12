'use strict';

angular.module('unshamed.login')
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
    if (len == 3) {
      text += " + 1 other."
    } else if (len > 3) {
      text += (convo.participants.length - 2) + " others"
    };

    return text;
  };


  // PRIVATE

  pusherHelperSvc.subscribeToNewReply(function(data) {
    console.log('NEW REPLY #show', data);
    if (vm.convo.id === data.conversation.id) {
      vm.convo.messages.push(data.message);
      convoSvc.addMessageToThread(data.message);
      vm.lastMessageAddedAt = data.message.created_at;
    }
  });
};


function conversationThreadDataFormatter(messages) {
  console.log(messages);
};
