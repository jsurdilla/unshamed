'use strict';

angular.module('unshamed')
  .directive('usNewCommentKeypress', usNewCommentKeypress)
  .controller('UserHomeCtrl', UserHomeCtrl);

usNewCommentKeypress.$inject = ['Comment'];
function usNewCommentKeypress(Comment) {
  return function (scope, element, attrs) {
    element.bind("keypress", function (event) {
      if (event.which === 13) {
        scope.$apply(function() {
          var post = scope.$eval(attrs.post);
          if (post.newComment && post.newComment.trim() !== "") {
             var newComment = new Comment({
               comment: post.newComment,
               commentable_id: post.id,
               commentable_type: 'Post'
             });

             Comment.save({ comment: newComment }, function(data) {
               post.newComment = "";

               var comment = new Comment(data.comment);
               comment.updateUpdatedAtFriendlyText();
               post.comments = post.comments || [];
               post.comments.push(comment);
             });

            event.preventDefault();
          } else {
            // no-op
          }
        });
      }
    });
  };
};

UserHomeCtrl.$inject = ['$scope', 'Me', 'User', 'Friend', 'Resource', 'Post', 'Comment', 'Support', '$auth'];
function UserHomeCtrl($scope, Me, User, Friend, Resource, Post, Comment, Support, $auth) {
  var vm = this,
      currentPage = 0;

  vm.items = [];
  vm.newPost = {};

  vm.statusUpdateActive = false;

  vm.postUpdate = function() {
    var newPost = new Post(vm.newPost);
    newPost.$save(function(post, headers) {
      vm.newPost = {};

      var post = new Post(post.post);
      post.updateUpdatedAtFriendlyText();
      vm.posts.splice(0, 0, post);
    });
  };

  function support(supportableObj, type) {
    var support = new Support({
      supportable_type: type,
      supportable_id: supportableObj.id
    });

    Support.toggle({ support: support }, function(data, headers) {
      if (data.result === 'deleted') {
        supportableObj.support_count -= 1;
      } else {
        supportableObj.support_count += 1;
      }
    }, function(data) {
      if (data.status === 404) {
        supportableObj.support_count -= 1;
      }
    });
  };

  vm.supportPost = function(post) {
    support(post, 'Post');
  };

  vm.supportJournalEntry = function(journalEntry) {
    support(journalEntry, 'JournalEntry');
  };

  vm.gettingMorePosts = false;
  vm.hasMore = true;
  vm.getMorePosts = function() {
    vm.gettingMorePosts = true;
    currentPage += 1;
    getMoreRequests();
  };

  $(function() {
    setTimeout(function() {
    $('#status-update textarea').flexible();
    $('.post .actions textarea').flexible();
    }, 2000);
  });

  $scope.$on('$destroy', function() {
    console.log('Destroying...');
  });

  User.mostRecent().$promise.then(function(data) {
    vm.newMembers = data.users;
  });

  Friend.query().$promise.then(function(data) {
    vm.friends = data.users;
  });

  Resource.query().$promise.then(function(data) {
    vm.resources = data.resources;
  });

  function getMoreRequests() {
    Me.timeline({ page: currentPage }).$promise.then(function(data) {
      if (data.items.length === 0) {
        vm.hasMore = false;
      }
      var items = data.items;
      vm.items = vm.items.concat(items);

      // Comment.query({ post_ids: _.pluck(data.posts, 'id').join(',') }).$promise.then(function(data) {
      //   var postComments = {};
      //   var comments = _.map(data.comments, function(comment) {
      //     comment = new Comment(comment);
      //     if (comment.commentable_type === 'Post') {
      //       postComments[comment.commentable_id] = postComments[comment.commentable_id] || [];
      //       postComments[comment.commentable_id].push(comment);
      //     }
      //     return comment;
      //   });

      //   _.forEach(posts, function(post) {
      //     post.comments = postComments[post.id];
      //   })

      //   updateCommentUpdatedAt(comments);
      // });

      updatePostUpdatedAt(items);

      vm.gettingMorePosts = false;
    });
  }

  function updatePostUpdatedAt(posts) {
    _.each(posts, function(post) {
      post.updated_at_friendly = moment(post.updated_at).fromNow();
    });
  }

  function updateCommentUpdatedAt(comments) {
    _.each(comments, function(comment) {
      comment.updateUpdatedAtFriendlyText();
    });
  }

};
