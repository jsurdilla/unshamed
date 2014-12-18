/**
 * @jsx React.DOM
 */

var ConversationList = React.createClass({displayName: "ConversationList",
  render: function() {
    return (
      React.createElement("div", {class: "msgs"}
      )
    );
  }
});


angular.module('unshamed')
  .value('ConversationList', ConversationList);
