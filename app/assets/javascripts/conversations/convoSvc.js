'use strict';

angular.module('unshamed')
  .service('convoSvc', convoSvc);

convoSvc.$inject = ['$rootScope', '$auth', 'ipCookie', 'Conversation', 'pusherHelperSvc'];
function convoSvc($rootScope, $auth, ipCookie, Conversation, pusherHelperSvc) {
  var self = this,
      pusher = $rootScope.pusher,
      currentConversation = null,
      thread = null;

  self.convos = [];

  // PUBLIC

  self.lastConversationID = function() {
    return ipCookie('lastConversationID');
  };

  self.setCurrentConversation = function(conversation) {
    currentConversation = conversation;
    if (conversation) {
      ipCookie('lastConversationID', conversation.id);
    } else {
      ipCookie.remove('lastConversationID');
    }
  };

  self.getMostRecent = function() {
    var promise = Conversation.query({}).$promise;
    promise.then(function(data) {
      self.convos = data;
    });
    return promise;
  };

  self.prependConvo = function(convo) {
    self.convos.splice(0, 0, new Conversation(convo));
  }

  self.markAsRead = function(conversation) {
    matchingConversation(conversation).read = true;
  };

  self.addMessageToThread = function(message) {
    thread.addMessage(message);
  };

  self.toThreadFormat = function(messages) {
    thread = new ConversationThread(messages);
    self.sections = thread.sections;
  };

  // PRIVATE

  function matchingConversation(conversation) {
    return _.find(self.convos, function(convo) {
      return convo.id === conversation.id;
    });
  };

  // SETUP

  pusherHelperSvc.subscribeToNewMessage(function(data) {
    self.prependConvo(data.conversation);
  });

  pusherHelperSvc.subscribeToNewReply(function(data) {
    console.log('NEW REPLY', data);
    var matching = matchingConversation(data.conversation);
    if (matching) {
      matching.most_recent_message = data.message.body
      matching.read = false;
    };
    $rootScope.$apply();  
  });

  $rootScope.$on('new-reply-sent', function(event, data) {
    var matching = matchingConversation(data.conversation);
    if (matching) {
      matching.most_recent_message = data.message.body
    };
  });

};