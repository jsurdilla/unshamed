'use strict';

angular.module('unshamed')
  .controller('JournalEntryNewCtrl', JournalEntryNewCtrl);

JournalEntryNewCtrl.$inject = ['JournalEntry'];
function JournalEntryNewCtrl(JournalEntry) {
  var vm = this;

  vm.save = function() {
    JournalEntry.save({ journal_entry: vm.journalEntry }).$promise.then(function(data) {
    });
  }

};
