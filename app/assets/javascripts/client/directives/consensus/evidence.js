(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('evidence', evidence);

  function evidence() {
    return {
      restrict: 'E',
      replace: true,
      scope: {
        'questionId': '@'
      },
      templateUrl: 'client/views/shared/responses/evidence.html',
      controller: 'EvidenceCtrl',
      controllerAs: 'evidence'
    }
  }
})();
