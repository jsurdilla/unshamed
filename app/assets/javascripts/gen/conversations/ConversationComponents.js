/**
 * @jsx React.DOM
 */

angular.module('unshamed.conversations')
  .factory('ConversationMessage', ConversationMessage)
  .factory('ConversationSection', ConversationSection)
  .factory('ConversationList', ConversationList);

ConversationMessage.$inject = ['$filter'];
function ConversationMessage($filter) {
  return React.createClass({
    render: function() {
      var message = this.props.message;

      return (
        React.createElement("div", {className: "clearfix msg"}, 
          React.createElement("div", {className: "time"},  $filter('date')(message.sentAt.toDate(), 'shortTime') ), 
          React.createElement("div", {className: "body"},  message.body)
        )
      );
    }
  });
};

ConversationSection.$inject = ['$filter', 'ConversationMessage'];
function ConversationSection($filter, ConversationMessage) {
  return React.createClass({
    render: function() {
      var section = this.props.section;
      var messages = section.messages.map(function(message) {
        return (
          React.createElement(ConversationMessage, {message: message, key: message.id})
        );
      });

      return (
        React.createElement("li", {className: "clearfix section"}, 
          React.createElement("h4", {"ng-show": "section.newDay"},  $filter('date')(section.timestamp.toDate(), 'mediumDate') ), 

          React.createElement("div", {className: "profile-pic"}, 
            React.createElement("img", {src:  section.messages[0].sender.profile_pictures.square50})
          ), 

          React.createElement("div", {className: "msgs"}, 
           messages 
          )
        )
      );
    }
  });
};

ConversationList.$inject = ['$rootScope', 'Conversation', 'ConversationSection', 'pusherHelperSvc', 'ReverseInfiniteScroll'];
function ConversationList($rootScope, Conversation, ConversationSection, pusherHelperSvc, ReverseInfiniteScroll) {
  return ConversationList = React.createClass({displayName: "ConversationList",
    getInitialState: function() {
      this.initial = true;
      this.messages = [];

      return {
        hasMore: true,
        sections: []
      };
    },

    componentDidMount: function() {
      pusherHelperSvc.subscribeToNewReply(this._handleNewReply);
      this._loadMessages();
      this._newReplySentCallback = $rootScope.$on('new-reply-sent', this._handleNewReplySent);
    },

    componentWillUpdate: function() {
      var node = this.getDOMNode();
      this.previousHeight = node.scrollHeight;
    },

    componentDidUpdate: function() {
      if (this.initial) {
        this._scrollToBottom();
        this.initial = false;
      } else if (this.paging) {
        this._mainScrollPosition();
        this.paging = false;
      } else {
        this._scrollToBottom();
      }
    },

    componentWillUnmount: function() {
      pusherHelperSvc.unsubscribeToNewReply(this._handleNewReply);
    },

    _handleNewReply: function(data) {
      if (data.conversation.id === this._conversationId()) {
        this.messages.push(data.message);
        var thread = new ConversationThread(this.messages);
        this.setState({ sections: thread.sections });
      }
    },

    _handleNewReplySent: function(event, data) {
      this._handleNewReply(data);
    },

    // Guarantees that only one message is sent at a time.
    _loadMessages: function() {
      // include the oldest message's ID as the paging parameter
      var params = { id: this._conversationId() };
      if (this.messages.length > 0) {
        params['message_id'] = this.messages[0].id;
      }

      if (this.previousPromise) {
        return;
      }

      this.previousPromise = Conversation.get(params).$promise;

      this.previousPromise.then(function(data) {
        var hasMore = data.messages.length > 0;
        this.messages = data.messages.concat(this.messages);
        var thread = new ConversationThread(this.messages);
        this.paging = true;
        this.setState({ sections: thread.sections, hasMore: hasMore });
        delete this.previousPromise;
      }.bind(this));
    },

    _scrollToBottom: function() {
      var node = this.getDOMNode();
      node.scrollTop = node.scrollHeight
    },

    _mainScrollPosition: function() {
      var node = this.getDOMNode();
      node.scrollTop = node.scrollHeight - this.previousHeight;
    },

    _conversationId: function() {
      return parseInt(this.props.conversationId);
    },

    render: function() {
      var sections = this.state.sections.map(function(section) {
        return (
          React.createElement(ConversationSection, {section: section, key: section.timestamp.toDate()})
        );
      });

      return (
          React.createElement(ReverseInfiniteScroll, {
            loadMore: _.throttle(this._loadMessages, 2000), 
            hasMore: this.state.hasMore, 
            threshold: 20, 
            loader: React.createElement("div", {className: "loader"}, "Loading ...")}, 
            React.createElement("ul", null, 
              sections
            )
          )
      );
    }
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
