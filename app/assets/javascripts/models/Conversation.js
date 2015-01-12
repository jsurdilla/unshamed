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

    return conversations;
  };


  var customActions = {
    get: {
      method: 'GET',
      isArray: false,
      transformResponse: function(data) {
        return new Conversation(JSON.parse(data).conversation);
      }
    },

    query: {
      method: 'GET',
      isArray: true,
      transformResponse: makeIntoConversationsArray
    },

    recipientAutocomplete: {
      method: 'GET',
      isArray: false,
      params: { verb: 'recipient_autocomplete' },
      transformResponse: function(data) {
        return new Conversation(JSON.parse(data));
      }
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

