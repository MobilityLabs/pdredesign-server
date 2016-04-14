PDRClient.controller('AssessmentSharedDashboardSidebarCtrl', [
  '$scope',
  '$stateParams',
  'SharedAssessment',
  function($scope, $stateParams, SharedAssessment) {
      var token = $stateParams.token;
      $scope.token = token;

      $scope.fetchAssessment = function() {
        return SharedAssessment.get({token: $scope.token});
      };

      $scope.assessment = $scope.fetchAssessment();

      $scope.meetingDateDaysAgo = function() {
        return moment().diff($scope.assessment.meeting_date, 'days');
      };

      $scope.postMeetingDate = function() {
        if(!$scope.assessment.meeting_date)
          return false;
        return moment().isAfter($scope.assessment.meeting_date);
      };

      $scope.preMeetingDate = function() {
        if(!$scope.assessment.meeting_date)
          return false;
        return moment().isBefore($scope.assessment.meeting_date);
      };

      $scope.noMeetingDate = function() {
        return $scope.assessment.meeting_date == null;
      };

      $scope.meetingDayNumber = function() {
        return moment($scope.assessment.meeting_date).format("D");
      };

      $scope.meetingDayName = function() {
        return moment($scope.assessment.meeting_date).format("dddd");
      };

      $scope.meetingMonthName = function() {
        return moment($scope.assessment.meeting_date).format("MMM");
      };     

      $scope.meetingDayName = function() {
        return moment($scope.assessment.meeting_date).format("dddd");
      };

      $scope.meetingMonthName = function() {
        return moment($scope.assessment.meeting_date).format("MMM");
      };     
    }
]);
