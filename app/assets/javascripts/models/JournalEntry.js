'use strict';

angular.module('unshamed.models')
  .factory('JournalEntry', JournalEntry);

JournalEntry.$inject = ['$resource'];
function JournalEntry($resource) {
  var customActions = {
    query: {
      method: 'GET',
      isArray: false
    },

    update: {
      method: 'PUT'
    }
  };

  var JournalEntry = $resource('/api/v1/journal_entries/:id/:verb', {
    id: '@id'
  }, customActions);

  return JournalEntry;
};

