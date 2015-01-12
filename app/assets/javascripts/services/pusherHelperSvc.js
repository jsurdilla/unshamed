'use strict';

angular.module('unshamed.services')
  .service('pusherHelperSvc', pusherHelperSvc);

pusherHelperSvc.$inject = ['$rootScope', '$auth', '$q'];
function pusherHelperSvc($rootScope, $auth, $q) {
  var self = this;

  // PUBLIC

  self.events = {
    NEW_MESSAGE: 'new-message',
    NEW_REPLY: 'new-reply'
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

  // callback - called when new message arrives
  // returns the subscription object that can be use to unsubscribe later.
  self.subscribeToNewMessage = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.NEW_MESSAGE, callback);
    });
  };

  self.subscribeToNewReply = function(callback) {
    $auth.validateUser().then(function() {
      var channel = self.mainChannel();
      channel.bind(self.events.NEW_REPLY, callback);
    });
  };

};
