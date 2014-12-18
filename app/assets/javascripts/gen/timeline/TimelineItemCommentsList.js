/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemCommentsList', TimelineItemCommentsList);

TimelineItemCommentsList.$inject = ['TimelineItemCommentItem'];
function TimelineItemCommentsList(TimelineItemCommentItem) {
  return React.createClass({
    render: function() {
      var comments = this.props.comments;

      if (comments) {
        var commentsEl = comments.map(function(comment) {
          return (
            React.createElement(TimelineItemCommentItem, {comment: comment, key: comment.id})
          );
        });

      }

      return (
        React.createElement("ul", {className: "comments"}, 
           commentsEl ? commentsEl : ''
        )
      )
    }
  });
};