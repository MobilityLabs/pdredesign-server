PDRClient.controller('AssessmentReportCtrl', [
  '$scope', 
  '$http',
  '$timeout', 
  '$anchorScroll',
  '$location', 
  '$stateParams',
  'SessionService', 
  'Assessment', 
  'Report',
  'Consensus',
  'AssessmentService',
  function($scope, $http, $timeout, $anchorScroll, $location, $stateParams, SessionService, Assessment, Report, Consensus, AssessmentService) {

      $scope.currentUser = SessionService.getCurrentUser();
      $scope.id = $stateParams.id;
      $scope.assessment = Assessment.get({id: $scope.id});
      $scope.assessment.$promise.then(function(assessment) {
        $scope.shareMailto = AssessmentService.shareMailto(assessment);
      });

      $scope.report = Report.get({assessment_id: $scope.id});

      $scope.isFacilitator = function() {
        return $scope.assessment.owner;
      };

      $scope.canEditPriorities = function() {
        return $scope.isFacilitator();
      };
    }
]);
