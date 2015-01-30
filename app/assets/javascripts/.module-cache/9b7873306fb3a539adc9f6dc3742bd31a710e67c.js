/**
 * @jsx React.DOM
 */

var Message = React.createClass({displayName: "Message",
  render: function() {
    return (
      React.createElement("div", null, "MESSAGE")
    );
  }
});

var Section = React.createClass({displayName: "Section",
  render: function() {
    return (
      React.createElement("li", {className: "clearfix section"}
      )
    );
  }
});

var ConversationList = React.createClass({displayName: "ConversationList",
  render: function() {
    var sections = this.props.sections.map(function(section) {
      return (
        React.createElement(Section, null)
      );
    });

    return (
      React.createElement("ul", {class: "messages"}, 
        sections 
      )
    );
  }
});


angular.module('unshamed')
  .value('ConversationList', ConversationList);
