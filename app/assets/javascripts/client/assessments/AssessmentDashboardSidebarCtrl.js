(function() {
    'use strict';
    angular.module('PDRClient')
        .controller('AssessmentDashboardSidebarCtrl', AssessmentDashboardSidebarCtrl);

    AssessmentDashboardSidebarCtrl.$inject = [
        '$scope',
        '$modal',
        '$location',
        'Assessment',
        '$stateParams',
        'Reminder',
        'AssessmentService'
    ];

    function AssessmentDashboardSidebarCtrl($scope, $modal, $location, Assessment, $stateParams, Reminder, AssessmentService) {

        $scope.id = $stateParams.id;

        $scope.fetchAssessment = function () {
            return Assessment.get({id: $scope.id});
        };

        $scope.assessment = $scope.fetchAssessment();

        $scope.modifySchedule = function () {
            $scope.modal = $modal.open({
                templateUrl: 'client/views/modals/modify_schedule.html',
                scope: $scope
            });
        };

        $scope.createConsensus = function () {
            $scope.modal = $modal.open({
                templateUrl: 'client/views/modals/create_consensus.html',
                scope: $scope
            });
        };

        $scope.redirectToCreateConsensus = function () {
            $scope.close();
            $location.url('/assessments/' + $scope.id + '/consensus');
        };

        $scope.newReminder = function () {
            $scope.modal = $modal.open({
                templateUrl: 'client/views/modals/new_reminder.html',
                scope: $scope
            });
        };

        $scope.close = function () {
            $scope.modal.dismiss('cancel');
        };

        $scope.sendReminder = function (message) {
            Reminder
                .save({assessment_id: $scope.id}, {message: message})
                .$promise
                .then(function () {
                    $scope.close();
                });
        };

        $scope.addLearningQuestion = function () {
            $scope.modal = $modal.open({
                template: '<learning-question-modal reminder="false" />',
                scope: $scope
            });
        };

        $scope.meetingDateDaysAgo = function () {
            return moment().diff($scope.assessment.meeting_date, 'days');
        };

        $scope.postMeetingDate = function () {
            if (!$scope.assessment.meeting_date)
                return false;
            return moment().isAfter($scope.assessment.meeting_date);
        };

        $scope.preMeetingDate = function () {
            if (!$scope.assessment.meeting_date)
                return false;
            return moment().isBefore($scope.assessment.meeting_date);
        };

        $scope.noMeetingDate = function () {
            return $scope.assessment.meeting_date == null;
        };

        $scope.reportPresent = function () {
            return $scope.assessment.submitted_at !== null;
        };

        $scope.meetingDayNumber = function () {
            return moment($scope.assessment.meeting_date).format('D');
        };

        $scope.meetingDayName = function () {
            return moment($scope.assessment.meeting_date).format('dddd');
        };

        $scope.meetingMonthName = function () {
            return moment($scope.assessment.meeting_date).format('MMM');
        };

        $scope.consensusStarted = function () {
            return $scope.assessment.status == 'consensus';
        };

        $scope.showShareReport = function () {
          $scope.shareReportUrl = AssessmentService.sharedUrl($scope.assessment.share_token);
          $scope.shareModal = $modal.open({
              templateUrl: 'client/views/modals/share_report.html',
              animation: true,
              scope: $scope
          });
        };

        $scope.closeShareModal = function () {
            $scope.shareModal.dismiss('cancel');
        };

        $scope.$on('close-learning-question-modal', function() {
          $scope.modal.close('cancel');
        });
    }
})();
