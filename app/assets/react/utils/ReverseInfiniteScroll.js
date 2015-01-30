/**
 * @jsx React.DOM
 */

angular.module('unshamed.utils')
  .factory('ReverseInfiniteScroll', ReverseInfiniteScroll);

function ReverseInfiniteScroll() {
  return React.createClass({
    displayName: 'ReverseInfiniteScroll',
    propTypes: {
      threshold: React.PropTypes.number,
      loadMore: React.PropTypes.func.isRequired,
      hasMore: React.PropTypes.bool
    },
    getDefaultProps: function () {
      return {
        hasMore: false,
        threshold: 250
      };
    },
    componentDidMount: function () {
      this.attachScrollListener(true);
    },
    componentWillUpdate: function() {
      var el = this.getDOMNode();
    },
    componentDidUpdate: function () {
      this.attachScrollListener();
    },
    render: function () {
      var props = this.props;
      return React.DOM.div({ className: 'messages' }, props.children, props.hasMore);
    },
    scrollListener: _.throttle(function () {
      var el = this.getDOMNode();
      if (this.props.isReady && el.scrollTop < Number(this.props.threshold)) {
        this.detachScrollListener();
        this.props.loadMore();
      }
    }, 1000),
    attachScrollListener: function (force) {
      var el = this.getDOMNode();
      if (!this.props.hasMore || (!this.props.isReady && !force)) {
        return;
      }
      el.addEventListener('scroll', this.scrollListener);
      el.addEventListener('resize', this.scrollListener);
      this.scrollListener();
    },
    detachScrollListener: function () {
      var el = this.getDOMNode();
      el.removeEventListener('scroll', this.scrollListener);
      el.removeEventListener('resize', this.scrollListener);
    },
    componentWillUnmount: function () {
      this.detachScrollListener();
    }
  });
}

ReverseInfiniteScroll.setDefaultLoader = function (loader) {
  ReverseInfiniteScroll._defaultLoader = loader;
};


function topPosition(domElt) {
  if (!domElt) {
    return 0;
  }
  return domElt.offsetTop + topPosition(domElt.offsetParent);
}
