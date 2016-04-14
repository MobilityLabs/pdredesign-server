(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('StartAssessmentCtrl', StartAssessmentCtrl);

  StartAssessmentCtrl.$inject = [
    '$scope',
    '$timeout',
    '$location',
    '$modal',
    'Assessment',
    'SessionService'
  ];

  function StartAssessmentCtrl($scope, $timeout, $location, $modal, Assessment, SessionService) {
    var vm = this;

    vm.user = SessionService.getCurrentUser();
    vm.district = vm.user.districts[0];

    vm.alerts = [];
    vm.assessment = {};

    vm.hideModal = function() {
      $('#startAssessment').modal('hide');
    };

    vm.noDistrict = function() {
      return _.isEmpty(vm.user.district_ids);
    };

    vm.redirectToAssessment = function(assessment) {
      vm.hideModal();
      $location.path('assessments/' + assessment.id + '/assign');
    };

    vm.create = function(assessment) {
      assessment.due_date = moment($("#due-date").val(), 'MM-DD-YYYY').toISOString();
      assessment.district_id = vm.district.id;

      Assessment
          .create(assessment)
          .$promise
          .then(function(data) {
            vm.success('Assessment Created.');
            vm.redirectToAssessment(data);
          }, function(response) {
            var errors = response.data.errors;
            angular.forEach(errors, function(error, field) {
              vm.error(field + " : " + error);
            });
          });
    };

    vm.success = function(message) {
      vm.alerts.push({type: 'success', msg: message});
    };

    vm.error = function(message) {
      vm.alerts.push({type: 'danger', msg: message});
    };

    vm.closeAlert = function(index) {
      vm.alerts.splice(index, 1);
    };

    $timeout(function() {
      $scope.datetime = $('.datetime').datetimepicker({
        pickTime: false
      });

      $scope.datetime.on('dp.change', function(e) {
        $('#due-date').trigger('change');
      });
    });

    vm.isNetworkPartner = function() {
      return SessionService.isNetworkPartner();
    };

    vm.text = function() {
      if (vm.isNetworkPartner()) {
        return 'Recommend Assessment';
      }
      return 'Facilitate New Assessment';
    };

    vm.openAssessmentModal = function() {
      vm.assessmentModal = $modal.open({
        templateUrl: 'client/home/assessment_modal.html',
        scope: $scope
      });
    };

    SessionService.syncUser();
  }
})();