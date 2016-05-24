(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('analysisPriority', analysisPriority);

  function analysisPriority() {
    return {
      restrict: 'E',
      replace: true,
      scope: {},
      transclude: true,
      templateUrl: 'client/analyses/priority_table.html',
      controller: 'AnalysisPriorityCtrl',
      controllerAs: 'analysisPriority'
    }
  }
})();