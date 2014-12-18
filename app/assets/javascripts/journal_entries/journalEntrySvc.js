'use strict';

angular.module('unshamed')
  .service('journalEntrySvc', journalEntrySvc);

journalEntrySvc.$inject = ['JournalEntry', '$state'];
function journalEntrySvc(JournalEntry, $state) {
  var self = this;
  self.entries = [];

  self.startNewEntry = function() {
    self.current = new JournalEntry({ posted_at: new Date(), public: false });
  };

  self.setCurrent = function(journalEntry) {
    self.current = new JournalEntry(journalEntry);
    linkCurrentToExistingEntries();
  };

  self.getMostRecent = function(refresh) {
    var promise = JournalEntry.query({}).$promise;
    promise.then(function(data) {
      var entries = data.journal_entries.map(function(entry) {
        return new JournalEntry(entry);
      });

      if (refresh) {
        self.entries = entries;
      } else {
        self.entries = self.entries.concat(entries);
      }
      linkCurrentToExistingEntries();
    });
    return promise;
  };

  self.saveCurrent = function() {
    if (self.current.id) {
      self.current.$update(function(journalEntry) {
        self.setCurrent(journalEntry);
      });
    } else {
      self.current.$save(function(data) {
        self.getMostRecent(true);
        $state.go('journalEntries.show', { id: data.journal_entry.id });
      });
    }
  };

  function linkCurrentToExistingEntries() {
    if (self.entries && self.current) {
      var existing = _.find(self.entries, function(entry) {
        return entry.id === self.current.id;
      });

      if (existing) {
        self.current = existing;
      }
    }
  };

  self.startNewEntry();
  self.getMostRecent();
};
