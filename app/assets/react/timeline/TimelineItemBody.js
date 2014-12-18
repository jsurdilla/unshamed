/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemBody', TimelineItemBody);

TimelineItemBody.$inject = [];
function TimelineItemBody() {
  return React.createClass({
    render: function() {
      var item = this.props.item;

      if (item.type === 'Post') {
        return (
          <div className='body'>
            <div className='content'>{item.body}</div>
            <a className='support' onClick={this.handleSupportClick}>Support</a>
          </div>
        );
      } else if (item.type === 'JournalEntry') {
        return (
          <div className='body'>
            <div className='content'>
              <img className='journal-icon' src='/assets/journal.png' />
              <div>
                <h4>{item.title}</h4>
                <div className='entry-body' dangerouslySetInnerHTML={{__html: item.body}}></div>
              </div>
            </div>
            <a className='support' onClick={this.handleSupportClick}>Support</a>
          </div>
        );
      }
    },

    handleSupportClick: function(item) {
      this.props.onSupportClick(this.props.item);
    }
  });
};