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
        <li className='clearfix'>
          <img src={comment.author.profile_pictures.square50} />
          <div className='name-time'>
            <a className='name' onClick={this.handleAuthorClick}>{comment.author.full_name}</a><br />
            <span className='time'>{relativeTime(comment.updated_at)}</span>
          </div>
          <div className='comment-body'>{comment.comment} </div>
        </li>
      );
    }
  });
};

function relativeTime(time) {
  return moment(time).fromNow();
}
