PDRClient.controller('AssessmentSharedReportCtrl', [
  '$scope', 
  '$stateParams',
  'SharedAssessment', 
  'SharedReport',
  function($scope, $stateParams, SharedAssessment, SharedReport) {
      var token = $stateParams.token;
      $scope.token = token;
      $scope.assessment = SharedAssessment.get({token: token});
      $scope.report = SharedReport.get({token: token});
    }
]);
