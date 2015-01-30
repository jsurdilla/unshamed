/**
 * @jsx React.DOM
 */

window.ConversationList = React.createClass({displayName: "ConversationList",
  render: function() {
    return (
      React.createElement("ul", {className: "messages"}, 
        "Hello"
      )
    );
  }
});
