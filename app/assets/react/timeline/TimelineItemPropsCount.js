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
        var supportSpan = <span>{item.support_count} Support</span>
      } else {
        var supportSpan = <span>Be the first to support this.</span>
      }

      return (
        <div className='props-count'>
          {supportSpan}
        </div>
      );
    }
  });
};