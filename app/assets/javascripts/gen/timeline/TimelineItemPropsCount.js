/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemPropsCount', TimelineItemPropsCount);


TimelineItemPropsCount.$inject = [];
function TimelineItemPropsCount() {
  return React.createClass({
    render: function() {
      var item = this.props.item;
      if (item.support_count > 0) {
        var supportSpan = React.createElement("span", null, item.support_count, " Support")
      } else {
        var supportSpan = React.createElement("span", null, "Be the first to support this.")
      }

      return (
        React.createElement("div", {className: "props-count"}, 
          supportSpan
        )
      );
    }
  });
};