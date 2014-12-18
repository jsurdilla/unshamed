/**
 * @jsx React.DOM
 */

angular.module('unshamed.users')
  .factory('TimelineItemHeader', TimelineItemHeader);

TimelineItemHeader.$inject = ['$state'];
function TimelineItemHeader($state) {
  return React.createClass({
    handleAuthorClick: function(e) {
      e.preventDefault();
      $state.go('members.details', { id: this.props.item.author.id });
    },

    render: function() {
      var item = this.props.item;

      return (
        <div className='header'>
          <img className='author-pic' src={item.author.profile_pictures.square50} />
          <div>
            <a className='name' onClick={this.handleAuthorClick}>{item.author.full_name}</a>
            <div className='time'>{relativeTime(item.updated_at)}</div>
          </div>
        </div>
      );
    }
  });
};