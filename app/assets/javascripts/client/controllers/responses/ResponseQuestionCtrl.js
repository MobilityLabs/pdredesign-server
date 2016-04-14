(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ResponseQuestionCtrl', ResponseQuestionCtrl);

  ResponseQuestionCtrl.$inject = [
    '$scope',
    '$rootScope',
    '$timeout',
    '$stateParams',
    '$location',
    'Response',
    'ResponseHelper'
  ];

  function ResponseQuestionCtrl($scope, $rootScope, $timeout, $stateParams, $location, Response, ResponseHelper) {

    $scope.isConsensus = false;

    $scope.questionColor = ResponseHelper.questionColor;
    $scope.saveEvidence = ResponseHelper.saveEvidence;
    $scope.editAnswer = ResponseHelper.editAnswer;
    $scope.answerTitle = ResponseHelper.answerTitle;

    $scope.toggleCategoryAnswers = function(category) {
      console.log($stateParams);
      category.toggled = !category.toggled;
      angular.forEach(category.questions, function(question, key) {
        ResponseHelper.toggleCategoryAnswers(question);
      });
    };

    $scope.toggleAnswers = function(question, $event) {
      ResponseHelper.toggleAnswers(question, $event);
    };

    $scope.invalidEvidence = function(question) {
      return question.score.evidence == null || question.score.evidence == '';
    };

    $scope.assignAnswerToQuestion = function(answer, question) {
      question.skipped = false;
      question.score.value = answer.value;
      if ($scope.invalidEvidence(question)) return;

      ResponseHelper.assignAnswerToQuestion($scope, answer, question);
    };

    $scope.$on('submit_response', function() {
      Response
          .submit({assessment_id: $stateParams.assessment_id, id: $stateParams.response_id}, {submit: true})
          .$promise
          .then(function(data) {
            $location.path('/assessments');
          });
    });

    $timeout(function() {
      $rootScope.$broadcast('start_change');
      Response
          .get({assessment_id: $stateParams.assessment_id, id: $stateParams.response_id})
          .$promise
          .then(function(data) {
            $scope.categories = data.categories;
            $rootScope.$broadcast('success_change');
          });
    });
  }
})();