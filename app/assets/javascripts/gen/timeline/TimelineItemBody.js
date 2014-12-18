/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemBody', TimelineItemBody);

TimelineItemBody.$inject = [];
function TimelineItemBody() {
  return React.createClass({
    render: function() {
      var item = this.props.item;

      if (item.type === 'Post') {
        return (
          React.createElement("div", {className: "body"}, 
            React.createElement("div", {className: "content"}, item.body), 
            React.createElement("a", {className: "support", onClick: this.handleSupportClick}, "Support")
          )
        );
      } else if (item.type === 'JournalEntry') {
        return (
          React.createElement("div", {className: "body"}, 
            React.createElement("div", {className: "content"}, 
              React.createElement("img", {className: "journal-icon", src: "/assets/journal.png"}), 
              React.createElement("div", null, 
                React.createElement("h4", null, item.title), 
                React.createElement("div", {className: "entry-body", dangerouslySetInnerHTML: {__html: item.body}})
              )
            ), 
            React.createElement("a", {className: "support", onClick: this.handleSupportClick}, "Support")
          )
        );
      }
    },

    handleSupportClick: function(item) {
      this.props.onSupportClick(this.props.item);
    }
  });
};