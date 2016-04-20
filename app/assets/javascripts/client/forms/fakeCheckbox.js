(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('fakeCheckbox', fakeCheckbox);
  
  function fakeCheckbox () {
    return {
      restrict: 'E',
      scope: {
        model: '=',
        required: '='
      },
      replace: true,
      templateUrl: 'client/forms/fake_checkbox.html'
    }
  };
})();
