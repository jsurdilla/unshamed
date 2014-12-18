'use strict';

angular.module('unshamed')
  .controller('JournalIndexCtrl', JournalIndexCtrl);

JournalIndexCtrl.$inject = ['JournalEntry', '$sce'];
function JournalIndexCtrl(JournalEntry, $sce) {
  var vm = this;
      vm.$sce = $sce;

  JournalEntry.query({}).$promise.then(function(data) {
    vm.entries = data.journal_entries;
  });

};

