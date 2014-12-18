/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemCommentItem', TimelineItemCommentItem)

TimelineItemCommentItem.$inject = ['$state'];
function TimelineItemCommentItem($state) {
  return React.createClass({
    handleAuthorClick: function(e) {
      e.preventDefault();
      $state.go('members.details', { id: this.props.comment.author.id });
    },

    render: function() {
      var comment = this.props.comment;

      return (
        React.createElement("li", {className: "clearfix"}, 
          React.createElement("img", {src: comment.author.profile_pictures.square50}), 
          React.createElement("div", {className: "name-time"}, 
            React.createElement("a", {className: "name", onClick: this.handleAuthorClick}, comment.author.full_name), React.createElement("br", null), 
            React.createElement("span", {className: "time"}, relativeTime(comment.updated_at))
          ), 
          React.createElement("div", {className: "comment-body"}, comment.comment, " ")
        )
      );
    }
  });
};

function relativeTime(time) {
  return moment(time).fromNow();
}
