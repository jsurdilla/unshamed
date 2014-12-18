/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItem', TimelineItem);

TimelineItem.$inject = ['TimelineItemHeader', 'TimelineItemBody', 'TimelineItemPropsCount', 'TimelineItemCommentsSection', 'Comment', 'Support', 'pusherHelperSvc'];
function TimelineItem(TimelineItemHeader, TimelineItemBody, TimelineItemPropsCount, TimelineItemCommentsSection, Comment, Support, pusherHelperSvc) {
  return React.createClass({
    getInitialState: function() {
      return {
        comments: [],
        supportCount: 0
      }
    },

    componentWillMount: function() {
      console.log("componentWillMount");
      // Subscribe to new comment notification
      pusherHelperSvc.subscribeToNewComment(function(data) {
        var comment = data.comment;
        var item = this.props.item;

        if (comment.commentable_id === item.id && comment.commentable_type === item.type) {
          item.comments.push(comment);
          this.setState({ comments: item.comments });
        }
      }.bind(this));

      pusherHelperSvc.subscribeToSupportCountChange(function(data) {
        var item = this.props.item;
        if (data.supportable_type = item.type && data.supportable_id == item.id) {
          item.support_count += data.increment;
          this.setState({ supportCount: item.support_count });
        }
      }.bind(this));
    },

    render: function() {
      var item = this.props.item;
      var classNames = [s.underscored(item.type)];

      return (
        React.createElement("div", {className: classNames.join(' ')}, 
          React.createElement(TimelineItemHeader, {item: item}), 
          React.createElement(TimelineItemBody, {item: item, onSupportClick: this.handleSupportClick}), 
          React.createElement(TimelineItemPropsCount, {item: item}), 
          React.createElement(TimelineItemCommentsSection, {item: item, onCommentSubmit: this.handleCommentSubmit, onViewMore: this.handleViewMoreComments})
        )
      );
    },

        // Handler for when user clicks on the the Support link.
    handleSupportClick: function(item) {
      var support = new Support({
        supportable_type: item.type,
        supportable_id: item.id
      });

      Support.toggle({ support: support }, function(data, headers) {
        if (data.result === 'deleted') {
          item.support_count -= 1;
        } else {
          item.support_count += 1;
        }
        this.setState({ supportCount: item.support_count });
      }.bind(this), function(data) {
        if (data.status === 404) {
          item.support_count -= 1;
          this.setState({ supportCount: item.support_count });
        }
      }.bind(this));
    },

    // Handler for when user submits a new comment.
    handleCommentSubmit: function(item, comment) {
      var attrs = {
        comment: comment,
        commentable_id: item.id,
        commentable_type: item.type
      };

      Comment.save({ comment: attrs }, function(data) {
        var comments = item.comments || [];
        comments.push(new Comment(data.comment));
        item.comments = comments;
        this.setState({ comments: comments });
      }.bind(this));

    },

    handleViewMoreComments: function(item) {
      var req = Comment.nextPage({ commentId: this.props.item.comments[0].id }).$promise.then(function(data) {
        var comments = data.comments.concat(item.comments);
        item.comments = comments;
        item.comments._metadata = data._metadata;
        this.setState({ comments: comments });
      }.bind(this));
    }
  });
};