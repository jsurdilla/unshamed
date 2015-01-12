'use strict';

angular.module('unshamed')
  .controller('JournalIndexCtrl', JournalIndexCtrl)
  .controller('JournalEntryEditCtrl', JournalEntryEditCtrl);


JournalIndexCtrl.$inject = ['$scope', 'JournalEntry', '$sce', 'journalEntrySvc', '$state'];
function JournalIndexCtrl($scope, JournalEntry, $sce, journalEntrySvc, $state) {
  journalEntrySvc.startNewEntry();
  $scope.journalEntrySvc = journalEntrySvc;

  var vm = this;
  vm.$sce = $sce;

  vm.save = function(entry) {
    entry.$save(function(data) {
      journalEntrySvc.getMostRecent(true);
      $state.go('journalEntries.show', { id: data.journal_entry.id });
    });
  };
};


JournalEntryEditCtrl.$inject = ['JournalEntry', '$sce'];
function JournalEntryEditCtrl(JournalEntry, $sce) {
  var vm = this;
  vm.$sce = $sce;

  vm.mediumEditor = {
    titleOptions: {
      placeholder: 'Untitled',
      disableToolbar: true,
      forcePlainText: true,
      disableReturn: true
    },
    bodyOptions: {
      placeholder: 'Start writing',
      buttons: ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'quote', 'orderedlist', 'unorderedlist']
    }
  };

  vm.formattedDate = function() {
    return moment(vm.current.post_date).format('LL');
  };

  // Disable weekend selection
  vm.disabled = function(date, mode) {
    return ( mode === 'day' && ( date.getDay() === 0 || date.getDay() === 6 ) );
  };

  vm.toggleMin = function() {
    vm.minDate = vm.minDate ? null : new Date();
  };
  vm.toggleMin();

  vm.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    vm.opened = true;
  };

  vm.dateOptions = {
    formatYear: 'yy',
    startingDay: 1
  };

  vm.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
  vm.format = vm.formats[0];
};
