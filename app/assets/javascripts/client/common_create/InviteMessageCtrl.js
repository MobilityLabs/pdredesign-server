(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InviteMessageCtrl', InviteMessageCtrl);

  InviteMessageCtrl.$inject = [
    '$scope',
    'SessionService',
    'CreateService'
  ];

  function InviteMessageCtrl($scope, SessionService, CreateService) {
    var vm = this;

    vm.user = SessionService.getCurrentUser();
    vm.saving = false;

    vm.save = function(assessment, assign) {
      CreateService.saveAssessment(assessment, assign);
    };

    vm.assignAndSave = function(assessment) {
      CreateService.assignAndSaveAssessment(assessment);
    };

    vm.formattedDate = function(date) {
      return CreateService.formattedDate(date);
    };

    CreateService.loadScope($scope);

    $scope.$on('toggle-saving-state', function() {
      vm.saving = !vm.saving;
    });

    $scope.$watch('district', function(val) {
      CreateService.loadDistrict(val);
    });
  }
})();
