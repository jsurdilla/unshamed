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
            <TimelineItemCommentItem comment={comment} key={comment.id} />
          );
        });

      }

      return (
        <ul className='comments'>
          { commentsEl ? commentsEl : '' }
        </ul>
      )
    }
  });
};