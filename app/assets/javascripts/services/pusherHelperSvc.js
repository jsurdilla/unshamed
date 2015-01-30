'use strict';

angular.module('unshamed.services')
  .service('pusherHelperSvc', pusherHelperSvc);

pusherHelperSvc.$inject = ['$rootScope', '$auth', '$q'];
function pusherHelperSvc($rootScope, $auth, $q) {
  var self = this;

  // PUBLIC

  self.events = {
    NEW_MESSAGE:           'new-message',
    NEW_REPLY:             'new-reply',
    NEW_FRIEND_REQ:        'new-friend-request',
    CANCEL_FRIEND_REQ:     'cancel-friend-request',
    ACCEPTED_FRIEND_REQ:   'accepted-friend-req',
    REJECTED_FRIEND_REQ:   'rejected-friend-req',
    UNFRIEND:              'unfriend',
    NEW_COMMENT:           'new-comment',
    SUPPORT_COUNT_CHANGED: 'support-count-change'
  };

  self.mainChannelName = function() {
    return 'private-user' + $auth.user.id;
  }

  self.mainChannel = function() {
    var channel = $rootScope.pusher.channel(self.mainChannelName());
    if (channel) {
      return channel;
    }
    return $rootScope.pusher.subscribe(self.mainChannelName());
  };

  self.subscribeToNewMessage = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.NEW_MESSAGE, callback);
    });
  };

  self.subscribeToNewReply = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.baseChannel.bind(self.events.NEW_REPLY, callback);
    });
  };

  self.unsubscribeToNewReply = function(callback) {
    var channel = self.mainChannel();
    channel.baseChannel.unbind(self.events.NEW_REPLY, callback);
  };

  self.subscribeToNewFriendReq = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.NEW_FRIEND_REQ, callback);
    });
  };

  self.subscribeToCancelledFriendReq = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.CANCEL_FRIEND_REQ, callback);
    });
  };

  self.subscribeToAcceptedFriendReq = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.ACCEPTED_FRIEND_REQ, callback);
    });
  };

  self.subscribeToRejectedFriendReq = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.REJECTED_FRIEND_REQ, callback);
    });
  };

  self.subscribeToUnfriend = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.UNFRIEND, callback);
    });
  };

  self.subscribeToNewComment = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.NEW_COMMENT, callback);
    });
  };

  self.subscribeToSupportCountChange = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.SUPPORT_COUNT_CHANGED, callback);
    });
  };

};
