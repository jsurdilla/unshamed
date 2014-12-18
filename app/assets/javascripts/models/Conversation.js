'use strict';

angular.module('unshamed.models')
  .factory('Conversation', Conversation);

Conversation.$inject = ['$resource'];
function Conversation($resource) {

  function makeIntoConversationsArray(data) {
    data = JSON.parse(data);

    var conversations = _.map(data.conversations, function(conversation) {
      return new Conversation(conversation);
    });

    return { conversations: conversations };
  };


  var customActions = {
    inbox: {
      method: 'GET',
      isArray: false,
      params: { verb: 'inbox' },
      transformResponse: makeIntoConversationsArray
    },

    sentbox: {
      method: 'GET',
      isArray: false,
      params: { verb: 'sentbox' },
      transformResponse: makeIntoConversationsArray
    },

    reply: {
      method: 'POST',
      isArray: false,
      params: { verb: 'reply' }
    }
  };

  var Conversation = $resource('/api/v1/conversations/:id/:verb', {
    id: '@id'
  }, customActions);

  Conversation.prototype.partipantsDisplayText = function() {
    return _.pluck(this.participants, 'full_name').join(', ');
  };

  return Conversation;
};

