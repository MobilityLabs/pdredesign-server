(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('analysisPriorityTable', analysisPriorityTable);

  function analysisPriorityTable() {
    return {
      restrict: 'E',
      replace: true,
      scope: {},
      transclude: true,
      templateUrl: 'client/analyses/priority_table.html',
      controller: 'AnalysisPriorityTableCtrl',
      controllerAs: 'analysisPriorityTable'
    }
  }
})();
