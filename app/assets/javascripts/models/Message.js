'use strict';

angular.module('unshamed.models')
  .factory('Message', Message);

Message.$inject = ['$resource'];
function Message($resource) {

  var customActions = {
  };

  var Message = $resource('/api/v1/conversations/:conversationId/messages/:id/:verb', {
    conversationId: '@conversation_id',
    id: '@id'
  }, customActions);

  return Message;
};


