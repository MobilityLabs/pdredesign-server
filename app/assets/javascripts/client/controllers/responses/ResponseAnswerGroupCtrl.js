(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ResponseAnswerGroupCtrl', ResponseAnswerGroupCtrl);

  ResponseAnswerGroupCtrl.$inject = [
    '$stateParams',
    '$scope',
    'ResponseHelper',
    'ResponseValidationService'
  ];

  function ResponseAnswerGroupCtrl($stateParams, $scope, ResponseHelper, ResponseValidationService) {
    var vm = this;

    vm.responseId = $stateParams.response_id;
    vm.assessmentId = $stateParams.assessment_id;

    $scope.responseId = vm.responseId;
    $scope.assessmentId = vm.assessmentId;

    vm.assignAnswerToQuestion = function(answer, question) {
      if ($scope.isConsensus === 'true') {
        if (!(question && question.score) || (question.score.evidence === null || question.score.evidence === '')) {
          question.isAlert = true;
          return;
        }
        ResponseHelper.assignAnswerToQuestion($scope, answer, question);
      } else {
        if (ResponseValidationService.invalidEvidence(question)) {
          return;
        }
        question.skipped = false;
        question.score.value = answer.value;
        ResponseHelper.assignAnswerToQuestion($scope, answer, question);
      }
    };
  }
})();