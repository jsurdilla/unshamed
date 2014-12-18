'use strict';

angular.module('unshamed')
  .controller('JournalEntryShowCtrl', JournalEntryShowCtrl);

JournalEntryShowCtrl.$inject = ['JournalEntry', 'journalEntry'];
function JournalEntryShowCtrl(JournalEntry, journalEntry) {
  var vm = this;

  vm.save = function() {
    if (vm.entry.id) {
      JournalEntry.update({ id: vm.entry.id }, { journal_entry: vm.entry }).$promise.then(function(data) {
      });
    } else {
      JournalEntry.save({ journal_entry: vm.entry }).$promise.then(function(data) {
      });
    }
  };

  if (journalEntry) {
    journalEntry.$promise.then(function(data) {
      vm.entry = data.journal_entry;
    }, null);
  } else {
    vm.entry = new JournalEntry();
  }
};


