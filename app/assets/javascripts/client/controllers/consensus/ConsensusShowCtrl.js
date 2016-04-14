(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ConsensusShowCtrl', ConsensusShowCtrl);

  ConsensusShowCtrl.$inject = [
    '$scope',
    'SessionService',
    'Assessment',
    'ConsensusHelper',
    '$stateParams'
  ];

  function ConsensusShowCtrl($scope, SessionService, Assessment, ConsensusHelper, $stateParams) {
    $scope.user = SessionService.getCurrentUser();

    $scope.assessmentId = $stateParams.assessment_id;
    $scope.responseId = $stateParams.response_id;
    $scope.assessment = Assessment.get({id: $scope.assessmentId});

    $scope.exportToPDF = function() {
      ConsensusHelper.consensuToPDF($scope.assessmentId, $scope.responseId);
    };

    $scope.exportToCSV = function() {
      ConsensusHelper.consensuToCSV($scope.assessment, $scope.responseId);
    };
  }
})();
