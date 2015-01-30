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
    var section = this.props.section;
    console.log(section.timestamp.toDate());

    return (
      React.createElement("li", {className: "clearfix section"}, 
        React.createElement("h4", null,  section.timestamp.toDate() )
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
