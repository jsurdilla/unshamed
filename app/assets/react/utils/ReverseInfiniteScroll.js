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
      this.attachScrollListener();
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
      if (el.scrollTop < Number(this.props.threshold)) {
        this.detachScrollListener();
        this.props.loadMore();
      }
    }, 1000),
    attachScrollListener: function () {
      if (!this.props.hasMore) {
        return;
      }
      this.getDOMNode().addEventListener('scroll', this.scrollListener);
      window.addEventListener('resize', this.scrollListener);
      this.scrollListener();
    },
    detachScrollListener: function () {
      this.getDOMNode().removeEventListener('scroll', this.scrollListener);
      window.removeEventListener('resize', this.scrollListener);
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
