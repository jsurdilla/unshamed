/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemCommentsSection', TimelineItemCommentsSection)

TimelineItemCommentsSection.$inject = ['TimelineItemCommentsList', 'TimelineItemNewComment'];
function TimelineItemCommentsSection(TimelineItemCommentsList, TimelineItemNewComment) {
  return React.createClass({

    handleViewMoreClick: function() {
      this.props.onViewMore(this.props.item);
    },

    render: function() {
      var item = this.props.item;
      var comments = item.comments;

      if (comments && comments._metadata) {
        var viewMoreCount = comments._metadata.remaining < 20 ? comments._metadata.remaining : 20;
        if (viewMoreCount > 0) {
          var viewMoreEl = (
            <a className='view-more' onClick={this.handleViewMoreClick}>View {viewMoreCount} more</a>
          );
        }
    }

      return (
        <div className='actions clearfix'>
          { viewMoreEl ? viewMoreEl : '' }
          <TimelineItemCommentsList comments={comments} />
          <TimelineItemNewComment item={item} onCommentSubmit={this.props.onCommentSubmit} />
        </div>
      );
    }
  });
};