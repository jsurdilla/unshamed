/**
 * @jsx React.DOM
 */

var Message = React.createClass({displayName: "Message",
  render: function() {
    return (
      React.createElement("div", {className: "clearfix msg"}
      )
    );
  }
});

var Section = React.createClass({displayName: "Section",
  render: function() {
    var section = this.props.section;
    var messages = section.messages.map(function(message) {
      return (
        React.createElement(Message, {message: message})
      );
    });

    return (
      React.createElement("li", {className: "clearfix section"}, 
        React.createElement("h4", {"ng-show": "section.newDay"},  section.timestamp.toDate() ), 

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

var ConversationList = React.createClass({displayName: "ConversationList",
  render: function() {
    var sections = this.props.sections.map(function(section) {
      return (
        React.createElement(Section, {section: section})
      );
    });

    return (
      React.createElement("ul", {className: "messages"}, 
        sections 
      )
    );
  }
});


angular.module('unshamed')
  .value('ConversationList', ConversationList);
