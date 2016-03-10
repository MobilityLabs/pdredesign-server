PDRClient.directive('sharedTakeAway', [
  function() {
    return {
      restrict: 'E',
      replace: false,
      templateUrl: 'client/views/directives/take_away.html',
      scope: {
        token: '@',
      },
      controller: [
        '$scope',
        'SharedAssessment',
        function($scope, SharedAssessment) {
          $scope.assessment = {};

          SharedAssessment.get({token: $scope.token})
          .$promise.then(
            function(assessment) {
              $scope.assessment = assessment;
          });

          $scope.isFacilitator = function() {
            return $scope.assessment.is_facilitator == true;
          };

          $scope.isTakeawayEmpty = function() {
            return $scope.assessment.report_takeaway == null
                || $scope.assessment.report_takeaway == '';
          };
      }],
    };
}]);
