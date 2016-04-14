(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('disableEntry', disableEntry);

  function disableEntry() {
    return {
      restrict: 'C',
      link: function(scope, element) {
        if (!scope.entity.has_access) {
          element.css('opacity', '0.5');
        }
      }
    };
  }
})();
