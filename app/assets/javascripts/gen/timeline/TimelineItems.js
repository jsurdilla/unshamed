/**
 * @jsx React.DOM
 */

angular.module('unshamed.timeline.components')
  .factory('TimelineItems', TimelineItems);

TimelineItems.$inject = ['$auth', 'Comment', 'TimelineItem', 'InfiniteScroll', 'Me', 'StatusUpdateForm', 'Timeline'];
function TimelineItems($auth, Comment, TimelineItem, InfiniteScroll, Me, StatusUpdateForm, Timeline) {
  return React.createClass({
    getInitialState: function() {
      this.currentPage = 1;
      return { items: [] };
    },

    componentDidMount: function() {
      this.loadItemsFromServer();
      this.updateTimeInterval = setInterval(this._updateTime, 1000 * 60);
    },

    componentWillUnMount: function() {
      clearInterval(this.updateTimeInterval);
    },

    loadItemsFromServer: function() {
      if (this.props.mode === 'home') {
        Me.timeline({ page: this.currentPage }).$promise.then(injectCommentsAndSet.bind(this));
      } else if (this.props.mode === 'user') {
        Timeline.get({ user_id: this.props.userId, page: this.currentPage }).$promise.then(injectCommentsAndSet.bind(this));
      }

      function injectCommentsAndSet(data) {
        // fetch comments for the new page of items
        this.injectInitialComments(data.items).then(function() {
          items = this.state.items.concat(data.items);
          this.setState({ items: items, hasMore: data.items.length > 0 });
        }.bind(this));
      };
    },

    injectInitialComments: function(items) {
      var itemsByType     = _.groupBy(items, 'type');
      var postIds         = _.pluck(itemsByType.Post, 'id');
      var journalEntryIds = _.pluck(itemsByType.JournalEntry, 'id');

      // Get comments for posts and journal entries in the given array.
      var params = {
        post_ids:          postIds.join(','),
        journal_entry_ids: journalEntryIds.join(','),
        preview:           true
      };

      var request = Comment.query(params);
      request.$promise.then(function(data) {
        _.each(data.items, function(incomingItem) {
          var existingItem = _.find(items, function(item) {
            return item.id === incomingItem.item.id && item.type === incomingItem.item.type;
          });

          if (existingItem) {
            existingItem.comments = incomingItem.comments;
            existingItem.comments._metadata = incomingItem._metadata;
          }
        });
      });

      return request.$promise;
    },

    // prepend the status update.
    handleNewStatusUpdate: function(statusUpdate) {
      var items = this.state.items;
      items.splice(0, 0, statusUpdate);
      this.setState({ items: items });
    },

    render: function() {
      var items = this.state.items.map(function(item) {
        return (
          React.createElement(TimelineItem, {item: item, key: item.id})
        );
      });

      function loadFunc() {
        this.currentPage += 1;
        this.loadItemsFromServer();
      };

      // TODO: this logic belongs somewhere else, possibly a new component of
      // its own.
      if (this.props.mode === 'user' && $auth.user.id != this.props.userId) {
        var statusUpdateForm = '';
      } else {
        var statusUpdateForm = React.createElement(StatusUpdateForm, {onNewStatusUpdate: this.handleNewStatusUpdate});
      }

      return (
        React.createElement("div", null, 
          statusUpdateForm, 

          React.createElement("div", {className: "items"}, 
            React.createElement(InfiniteScroll, {pageStart: 0, 
              loadMore: _.throttle(loadFunc.bind(this), 2000), 
              hasMore: this.state.hasMore, 
              loader: React.createElement("div", {className: "loading-more"}, "Loading ...")}, 
              items
            )
          )
        )
      );
    },

    _updateTime: function() {
      this.setState({ now: new Date() });
    }
  });
};
