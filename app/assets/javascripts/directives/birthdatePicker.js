'use strict';

angular.module('unshamed.directives')
  .factory('birthdatePickerUtils', birthdatePickerUtils)
  .directive('birthdatePicker', birthdatePicker);

function birthdatePickerUtils() {
  var months = [
    { value: 1, label: 'January' },
    { value: 2, label: 'February' },
    { value: 3, label: 'March' },
    { value: 4, label: 'April' },
    { value: 5, label: 'May' },
    { value: 6, label: 'June' },
    { value: 7, label: 'July' },
    { value: 8, label: 'August' },
    { value: 9, label: 'September' },
    { value: 10, label: 'October' },
    { value: 11, label: 'November' },
    { value: 12, label: 'December' }
  ];

  var days = Array.apply(null, Array(31)).map(function (_, i) {
    return i+1;
  });

  var years = Array.apply(null, Array(50)).map(function (_, i) {
    return new Date().getFullYear() - i;
  });

  return {
    months: months,
    days: days,
    years: years
  };
};

birthdatePicker.$inject = [];
function birthdatePicker() {
  return {
    restrict: 'A',
    replace: true,
    require: 'ngModel',
    scope: {
      model: '=ngModel'
    },
    controller: ['$scope', 'birthdatePickerUtils', function($scope, birthdatePickerUtils) {
      $scope.dateFields = {};

      $scope.months = birthdatePickerUtils.months;
      $scope.days = birthdatePickerUtils.days;
      $scope.years = birthdatePickerUtils.years;

      $scope.checkDate = function() {
        var df = $scope.dateFields;
        $scope.model = checkDate(df.month + '/' + df.day + '/' + df.year);
      }

      function checkDate(str) {
        var matches = str.match(/(\d{1,2})[- \/](\d{1,2})[- \/](\d{4})/);
        if (!matches) return;

        // convert pieces to numbers
        // make a date object out of it
        var month = parseInt(matches[1], 10);
        var day = parseInt(matches[2], 10);
        var year = parseInt(matches[3], 10);
        var date = new Date(year, month - 1, day);
        if (!date || !date.getTime()) return;

        // make sure we didn't have any illegal
        // month or day values that the date constructor
        // coerced into valid values
        if (date.getMonth() + 1 != month ||
          date.getFullYear() != year ||
          date.getDate() != day) {
          return;
        }
        return(date);
      }
    }],
    templateUrl: 'directives/birthdate_picker.html',
    link: function(scope, element, attrs, ctrl) {
    }
  };
};
