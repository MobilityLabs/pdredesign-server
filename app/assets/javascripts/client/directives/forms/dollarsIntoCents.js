(function() {
  'use strict';
  angular.module('PDRClient')
    .directive('dollarsIntoCents', dollarsIntoCents);
    
    function dollarsIntoCents () {
      return {
        require: 'ngModel',
        restrict: 'A',
        link: dollarsIntoCentsLink
      }
    };

    function dollarsIntoCentsLink (scope, elem, attrs, ctrl) {
      // multiplicating by 100
      ctrl.$parsers.unshift( function (viewValue) {
        return Math.floor(viewValue * 100);
      });

      // dividing by 100
      ctrl.$formatters.push( function (viewValue) {
        return viewValue ? viewValue / 100 : viewValue;
      });
    };
})();
