/**
 * @jsx React.DOM
 */

var ConversationList = React.createClass({displayName: "ConversationList",
  render: function() {
    return (
      React.createElement("ul", null, 
        React.createElement("li", null, "Hello")
      )
    );
  }
});


debugger;
angular.module('unshamed')
  .value('ConversationList', ConversationList);
