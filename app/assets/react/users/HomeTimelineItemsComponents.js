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
        <li className='clearfix'>
          <img src={comment.author.profile_pictures.square50} />
          <div className='name-time'>
            <span className='name'>{comment.author.full_name}</span><br />
            <span className='time'>{relativeTime(comment.updated_at)}</span>
          </div>
          <div className='comment-body'>{comment.comment} </div>
        </li>
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
            <HomeTimelineItemCommentItem comment={comment} key={comment.id} />
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
        <div className='new-comment'>
          <div className='pic'>
            <img src={$auth.user.profile_pictures.square50} />
          </div>
          <div className='comment-box'>
            <textarea ref='commentBody' placeholder='Write a comment...' onKeyUp={this.checkCommentSubmission}></textarea>
          </div>
        </div>
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
            <a className='view-more' onClick={this.handleViewMoreClick}>View {viewMoreCount} more</a>
          );
        }
    }

      return (
        <div className='actions clearfix'>
          { viewMoreEl ? viewMoreEl : '' }
          <HomeTimelineItemCommentsList comments={comments} />
          <HomeTimelineItemNewComment item={item} onCommentSubmit={this.props.onCommentSubmit} />
        </div>
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
        <div className='props-count'>
          <span>{item.support_count} Support</span>
        </div>
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
          <div className='body'>
            <div className='content'>{item.body}</div>
            <a className='support' onClick={this.handleSupportClick}>Support</a>
          </div>
        );
      } else if (item.type === 'JournalEntry') {
        return (
          <div className='body'>
            <div className='content'>
              <img className='journal-icon' src='/assets/journal.png' />
              <div>
                <h4>{item.title}</h4>
                <div className='entry-body' dangerouslySetInnerHTML={{__html: item.body}}></div>
              </div>
            </div>
            <a className='support' onClick={this.handleSupportClick}>Support</a>
          </div>
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
        <div className='header'>
          <img className='author-pic' src={item.author.profile_pictures.square50} />
          <div>
            <a className='name' href='#'>{item.author.full_name}</a>
            <div className='time'>{relativeTime(item.updated_at)}</div>
          </div>
        </div>
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
        <div className={classNames.join(' ')}>
          <HomeTimelineItemHeader item={item} />
          <HomeTimelineItemBody item={item} onSupportClick={this.handleSupportClick} />
          <HomeTimelineItemPropsCount item={item} />
          <HomeTimelineItemCommentsSection item={item} onCommentSubmit={this.handleCommentSubmit} onViewMore={this.handleViewMoreComments} />
        </div>
      );
    }
  });
};

function relativeTime(time) {
  return moment(time).fromNow();
}
