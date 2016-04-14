(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('ResponseCtrl', ResponseCtrl);

  ResponseCtrl.$inject = [
    '$scope',
    '$timeout',
    '$stateParams',
    '$modal',
    'Assessment',
    'LearningQuestion'
  ];

  function ResponseCtrl($scope, $timeout, $stateParams, $modal, Assessment, LearningQuestion) {

    $scope.assessmentId = $stateParams.assessment_id;
    $scope.responseId = $stateParams.response_id;
    $scope.assessment = Assessment.get({id: $stateParams.assessment_id});


    $scope.$on('responses-loaded', function() {
      $timeout(function() {
        LearningQuestion.exists({assessment_id: $stateParams.assessment_id})
            .$promise
            .then(function() {
              // No-op - implies that a learning question exists for this user on this assessment
            }, function(err) {
              if (err.status === 404) {
                $scope.modal = $modal.open({
                  template: '<learning-question-modal reminder="true" />',
                  scope: $scope
                });
              }
            });
      });
    });

    $scope.$on('close-learning-question-modal', function() {
      $scope.modal.close('cancel');
    });
  }
})();
