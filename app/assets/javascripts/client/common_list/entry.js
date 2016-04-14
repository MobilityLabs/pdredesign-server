(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('entry', entry);

  function entry() {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        isAssessment: '@',
        entity: '='
      },
      templateUrl: 'client/common_list/entry_view.html',
      controller: 'EntryCtrl',
      controllerAs: 'entry',
      replace: true
    }
  }
})();