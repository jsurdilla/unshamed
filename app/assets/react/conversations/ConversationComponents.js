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
        <div className='clearfix msg'>
          <div className='time'>{ $filter('date')(message.sentAt.toDate(), 'shortTime') }</div>
          <div className='body'>{ message.body }</div>
        </div>
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
          <ConversationMessage message={message} key={message.id} />
        );
      });

      return (
        <li className='clearfix section'>
          <h4 ng-show='section.newDay'>{ $filter('date')(section.timestamp.toDate(), 'mediumDate') }</h4>

          <div className='profile-pic'>
            <img src={ section.messages[0].sender.profile_pictures.square50 } />
          </div>

          <div className='msgs'>
           { messages }
          </div>
        </li>
      );
    }
  });
};

ConversationList.$inject = ['convoSvc', 'Conversation', 'ConversationSection', 'ReverseInfiniteScroll'];
function ConversationList(convoSvc, Conversation, ConversationSection, ReverseInfiniteScroll) {
  return ConversationList = React.createClass({
    getInitialState: function() {
      return {
        hasMore: true,
        isReady: false,
        sections: []
      };
    },

    componentDidMount: function() {
      this.initial = true;
      Conversation.get({ id: this.props.conversationId }).$promise.then(function(data) {
        this.messages = data.messages;
        thread = new ConversationThread(data.messages);
        this.setState({ sections: thread.sections, hasMore: true });

        setTimeout(function() {
          var node = this.getDOMNode();
          node.scrollTop = node.scrollHeight
          this.setState({ hasMore: true, isReady: true });
          this.initial = false;
        }.bind(this), 100);
      }.bind(this));
    },

    componentWillUpdate: function() {
      if (this.initial) {
        return;
      }
      var node = this.getDOMNode();
      this.previousHeight = node.scrollHeight;
      node.scrollTop = node.scrollHeight;
    },

    componentDidUpdate: function() {
      if (this.initial) {
        return;
      }
      var node = this.getDOMNode();
      node.scrollTop = node.scrollHeight - this.previousHeight;
    },

    loadFunc: function() {
      Conversation.get({ id: this.props.conversationId, message_id: this.messages[0].id }).$promise.then(function(data) {
        var hasMore = data.messages.length > 0;
        this.messages = data.messages.concat(this.messages);
        thread = new ConversationThread(this.messages);
        this.setState({ sections: thread.sections, hasMore: hasMore });
      }.bind(this));
    },

    render: function() {
      var sections = this.state.sections.map(function(section) {
        return (
          <ConversationSection section={section} key={section.timestamp.toDate()} />
        );
      });

      return (
          <ReverseInfiniteScroll
            loadMore={_.throttle(this.loadFunc, 2000)}
            hasMore={this.state.hasMore}
            threshold={20}
            isReady={this.state.isReady}
            loader={<div className="loader">Loading ...</div>}>
            <ul>
              {sections}
            </ul>
          </ReverseInfiniteScroll>
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
