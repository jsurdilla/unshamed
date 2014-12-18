/**
 * @jsx React.DOM
 */

var ConversationListView = React.createClass({displayName: "ConversationListView",
  render: function() {
    return (
      React.createElement("ul", null, 
        React.createElement("li", null, "Hello")
      )
    );
  }
});


angular.module('unshamed')
  .value('ConversationListView', ConversationListView);
