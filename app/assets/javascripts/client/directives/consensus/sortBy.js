(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('sortBy', sortBy);

  function sortBy() {
    return {
      restrict: 'E',
      replace: true,
      transclude: true,
      scope: {
        data: '=',
        categories: '='
      },
      templateUrl: 'client/views/directives/consensus/sort_by.html',
      controller: 'SortByCtrl',
      controllerAs: 'sortBy'
    }
  }
})();