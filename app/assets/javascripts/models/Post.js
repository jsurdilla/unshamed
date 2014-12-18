'use strict';

angular.module('unshamed.models')
  .factory('Post', Post);

Post.$inject = ['$resource'];
function Post($resource) {
  var customActions = {
  };

  var Post = $resource('/api/v1/posts/:postId/:verb', {
    postId: '@postId'
  }, customActions);

  Post.prototype.updateUpdatedAtFriendlyText = function() {
    this.updated_at_friendly = moment(this.updated_at).fromNow();
  };

  return Post;
};

