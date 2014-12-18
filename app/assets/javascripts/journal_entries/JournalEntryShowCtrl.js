'use strict';

angular.module('unshamed')
  .controller('JournalEntryShowCtrl', JournalEntryShowCtrl);

JournalEntryShowCtrl.$inject = ['$scope', 'JournalEntry', 'journalEntry', '$sce', 'journalEntrySvc'];
function JournalEntryShowCtrl($scope, JournalEntry, journalEntry, $sce, journalEntrySvc) {
  $scope.journalEntrySvc = journalEntrySvc;
  journalEntrySvc.setCurrent(journalEntry.journal_entry);
};
