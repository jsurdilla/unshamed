/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemNewComment', TimelineItemNewComment);

TimelineItemNewComment.$inject = ['$auth'];
function TimelineItemNewComment($auth) {
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