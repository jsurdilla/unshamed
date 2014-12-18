/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemHeader', TimelineItemHeader);

TimelineItemHeader.$inject = ['$state'];
function TimelineItemHeader($state) {
  return React.createClass({
    handleAuthorClick: function(e) {
      e.preventDefault();
      $state.go('members.details', { id: this.props.item.author.id });
    },

    render: function() {
      var item = this.props.item;

      return (
        React.createElement("div", {className: "header"}, 
          React.createElement("img", {className: "author-pic", src: item.author.profile_pictures.square50}), 
          React.createElement("div", null, 
            React.createElement("a", {className: "name", onClick: this.handleAuthorClick}, item.author.full_name), 
            React.createElement("div", {className: "time"}, relativeTime(item.updated_at))
          )
        )
      );
    }
  });
};