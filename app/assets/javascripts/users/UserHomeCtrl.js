'use strict';

angular.module('unshamed.users')
  .directive('timelineItems', ['reactDirective', 'TimelineItems', function(reactDirective, TimelineItems) {
    return reactDirective('TimelineItems', ['mode', 'userId']);
  }])
  .controller('UserHomeCtrl', UserHomeCtrl);


UserHomeCtrl.$inject = ['$scope', 'Me', 'User', 'Friend', 'Mhp', 'Resource', 'Post', 'Comment', 'Support', '$auth', 'pusherHelperSvc'];
function UserHomeCtrl($scope, Me, User, Friend, Mhp, Resource, Post, Comment, Support, $auth, pusherHelperSvc) {
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
      vm.items.splice(0, 0, post);
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

  $(function() {
    setTimeout(function() {
      $('#status-update textarea').flexible();
    }, 1000);
  });

  User.mostRecent().$promise.then(function(data) {
    vm.newMembers = data.users;
  });

  Mhp.mostRecent().$promise.then(function(data) {
    vm.newMhps = data.users;
  });

  Friend.query().$promise.then(function(data) {
    vm.friends = data.users;
  });

  Resource.query().$promise.then(function(data) {
    vm.resources = data.resources;
  });

};
