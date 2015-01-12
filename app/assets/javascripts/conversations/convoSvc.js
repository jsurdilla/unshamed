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
    };
  });

};

function ConversationThread(messages) {
  var self = this;

  // Each section is a set of messages from the same user.
  self.sections = [];

  // PUBLIC

  self.addMessage = function(message) {
    var mostRecentSection = getMostRecentSection(),
        mostRecentMessage = getMostRecentMessage(),
        currentSentAt = moment(message.created_at);

    message.sentAt = moment(message.created_at);
    if (mostRecentMessage && areOnSameDay(currentSentAt, mostRecentMessage.sentAt)) {
      if (message.sender.id === mostRecentMessage.sender.id) {
        _.last(self.sections).messages.push(message);
      } else {
        pushNewSection(self.sections, message, { newDay: false });
      }
    } else {
      pushNewSection(self.sections, message, { newDay: true });
    }
  };

  // PRIVATE

  // Tests whether two dates are on the same day. Parameters must be both be
  // moment objects.
  function areOnSameDay(date1, date2) {
    return date1.year() === date2.year() && date1.dayOfYear() === date2.dayOfYear();
  };

  function pushNewSection(sections, message, options) {
    sections.push(_.merge({
      timestamp: message.sentAt,
      messages: [message]
    }, options || {}));
  };

  function getMostRecentSection() {
    return _.last(self.sections);
  };

  function getMostRecentMessage() {
    return _.last(getMostRecentSection().messages);
  };

  function main() {
    var lastMessage = null;
    _.each(messages, function(message) {
      var currentSentAt = new moment(message.created_at);
      message.sentAt = currentSentAt;

      if (lastMessage && areOnSameDay(currentSentAt, lastMessage.sentAt)) {
        if (message.sender.id === lastMessage.sender.id) {
          _.last(self.sections).messages.push(message);
        } else {
          pushNewSection(self.sections, message, { newDay: false });
        }
      } else {
        pushNewSection(self.sections, message, { newDay: true });
      }

      lastMessage = message;
    });
  };

  main();
};
