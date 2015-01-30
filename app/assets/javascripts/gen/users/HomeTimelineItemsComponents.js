/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('HomeTimelineItemHeader', HomeTimelineItemHeader)
  .factory('HomeTimelineItemBody', HomeTimelineItemBody)
  .factory('HomeTimelineItemPropsCount', HomeTimelineItemPropsCount)
  .factory('HomeTimelineItemCommentsSection', HomeTimelineItemCommentsSection)
  .factory('HomeTimelineItemCommentsList', HomeTimelineItemCommentsList)
  .factory('HomeTimelineItemCommentItem', HomeTimelineItemCommentItem)
  .factory('HomeTimelineItemNewComment', HomeTimelineItemNewComment)
  .factory('HomeTimelineItem', HomeTimelineItem);


HomeTimelineItemCommentItem.$inject = [];
function HomeTimelineItemCommentItem() {
  return React.createClass({
    render: function() {
      var comment = this.props.comment;

      return (
        React.createElement("li", {className: "clearfix"}, 
          React.createElement("img", {src: comment.author.profile_pictures.square50}), 
          React.createElement("div", {className: "name-time"}, 
            React.createElement("span", {className: "name"}, comment.author.full_name), React.createElement("br", null), 
            React.createElement("span", {className: "time"}, relativeTime(comment.updated_at))
          ), 
          React.createElement("div", {className: "comment-body"}, comment.comment, " ")
        )
      );
    }
  });
};

HomeTimelineItemCommentsList.$inject = ['HomeTimelineItemCommentItem'];
function HomeTimelineItemCommentsList(HomeTimelineItemCommentItem) {
  return React.createClass({
    render: function() {
      var comments = this.props.comments;

      if (comments) {
        var commentsEl = comments.map(function(comment) {
          return (
            React.createElement(HomeTimelineItemCommentItem, {comment: comment, key: comment.id})
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

HomeTimelineItemNewComment.$inject = ['$auth'];
function HomeTimelineItemNewComment($auth) {
  return React.createClass({
    checkCommentSubmission: function(e) {
      if (e.which === 13) {
        var commentBodyRef = this.refs.commentBody.getDOMNode();
        this.props.onCommentSubmit(this.props.item, commentBodyRef.value.trim());
        commentBodyRef.value = '';
      }
    },

    render: function() {
      var item = this.props.item;

      return (
        React.createElement("div", {className: "new-comment"}, 
          React.createElement("div", {className: "pic"}, 
            React.createElement("img", {src: $auth.user.profile_pictures.square50})
          ), 
          React.createElement("div", {className: "comment-box"}, 
            React.createElement("textarea", {ref: "commentBody", placeholder: "Write a comment...", onKeyUp: this.checkCommentSubmission})
          )
        )
      );
    }
  });
};

HomeTimelineItemCommentsSection.$inject = ['HomeTimelineItemCommentsList', 'HomeTimelineItemNewComment'];
function HomeTimelineItemCommentsSection(HomeTimelineItemCommentsList, HomeTimelineItemNewComment) {
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
            React.createElement("a", {className: "view-more", onClick: this.handleViewMoreClick}, "View ", viewMoreCount, " more")
          );
        }
    }

      return (
        React.createElement("div", {className: "actions clearfix"}, 
           viewMoreEl ? viewMoreEl : '', 
          React.createElement(HomeTimelineItemCommentsList, {comments: comments}), 
          React.createElement(HomeTimelineItemNewComment, {item: item, onCommentSubmit: this.props.onCommentSubmit})
        )
      );
    }
  });
};

HomeTimelineItemPropsCount.$inject = [];
function HomeTimelineItemPropsCount() {
  return React.createClass({
    render: function() {
      var item = this.props.item;

      return (
        React.createElement("div", {className: "props-count"}, 
          React.createElement("span", null, item.support_count, " Support")
        )
      );
    }
  });
};

HomeTimelineItemBody.$inject = [];
function HomeTimelineItemBody() {
  return React.createClass({
    handleSupportClick: function(item) {
      this.props.onSupportClick(this.props.item);
    },

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
    }
  });
};

HomeTimelineItemHeader.$inject = [];
function HomeTimelineItemHeader() {
  return React.createClass({
    render: function() {
      var item = this.props.item;

      return (
        React.createElement("div", {className: "header"}, 
          React.createElement("img", {className: "author-pic", src: item.author.profile_pictures.square50}), 
          React.createElement("div", null, 
            React.createElement("a", {className: "name", href: "#"}, item.author.full_name), 
            React.createElement("div", {className: "time"}, relativeTime(item.updated_at))
          )
        )
      );
    }
  });
};

HomeTimelineItem.$inject = ['HomeTimelineItemHeader', 'HomeTimelineItemBody', 'HomeTimelineItemPropsCount', 'HomeTimelineItemCommentsSection', 'Comment', 'Support', 'pusherHelperSvc'];
function HomeTimelineItem(HomeTimelineItemHeader, HomeTimelineItemBody, HomeTimelineItemPropsCount, HomeTimelineItemCommentsSection, Comment, Support, pusherHelperSvc) {
  return React.createClass({
    getInitialState: function() {
      return {
        comments: [],
        supportCount: 0
      }
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
    },

    componentWillMount: function() {
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
          React.createElement(HomeTimelineItemHeader, {item: item}), 
          React.createElement(HomeTimelineItemBody, {item: item, onSupportClick: this.handleSupportClick}), 
          React.createElement(HomeTimelineItemPropsCount, {item: item}), 
          React.createElement(HomeTimelineItemCommentsSection, {item: item, onCommentSubmit: this.handleCommentSubmit, onViewMore: this.handleViewMoreComments})
        )
      );
    }
  });
};

function relativeTime(time) {
  return moment(time).fromNow();
}
