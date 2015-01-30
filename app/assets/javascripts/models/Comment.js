'use strict';

angular.module('unshamed.models')
  .factory('Comment', Comment);

Comment.$inject = ['$resource'];
function Comment($resource) {
  var customActions = {
    query: {
      method: 'GET',
      isArray: false
    },

    nextPage: {
      method: 'GET',
      isArray: false,
      params: {
        verb: 'next_page'
      }
    }
  };

  var Comment = $resource('/api/v1/comments/:commentId/:verb', {
    commentId: '@commentId'
  }, customActions);

  Comment.prototype.updateUpdatedAtFriendlyText = function() {
    this.updated_at_friendly = moment(this.updated_at).fromNow();
  };

  return Comment;
};
