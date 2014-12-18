'use strict';

angular.module('unshamed.directives')
  .directive('scrollToBottom', scrollToBottom);

scrollToBottom.$inject = ['$timeout'];
function scrollToBottom($timeout) {
  return {
    restrict: 'A',
    scope: {
      scrollToBottom: '='
    },
    link: function(scope, elem, attrs) {
      scope.$watch('scrollToBottom', function(value) {
        if (!value) return;
        $timeout(function() {
          elem.scrollTop(elem[0].scrollHeight);
        }, 0);
      });
    }
  };
};
