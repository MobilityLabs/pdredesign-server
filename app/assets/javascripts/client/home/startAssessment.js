(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('startAssessment', startAssessment);

  function startAssessment() {
    return {
      restrict: 'E',
      replace: true,
      scope: {},
      templateUrl: 'client/home/start_assessment.html',
      controller: 'StartAssessmentCtrl',
      controllerAs: 'startAssessment'
    }
  }
})();