/**
 * @jsx React.DOM
 */

var ConversationList = React.createClass({displayName: "ConversationList",
  render: function() {
    return (
      React.createElement("ul", {className: "messages"}, 
        "Hello"
      )
    );
  }
});
