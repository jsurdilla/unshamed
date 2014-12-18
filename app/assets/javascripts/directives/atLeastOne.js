'use strict';

angular.module('unshamed.directives')
  .directive('atLeastOne', atLeastOne);

function atLeastOne() {
  return {
    require: 'ngModel',
    link: function(scope, elem, attrs, ngModel) {
      scope.$watchCollection(attrs.ngModel, function(value) {
        ngModel.$setValidity('atLeastOne', value && value.length != 0);
      });
    }
  };
};
