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