(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ManageParticipantsModalCtrl', ManageParticipantsModalCtrl);

  ManageParticipantsModalCtrl.$inject = [
    '$scope',
    '$window',
    '$stateParams',
    'AssessmentPermission',
    'Participant'
  ];

  function ManageParticipantsModalCtrl($scope, $window, $stateParams, AssessmentPermission, Participant) {
    var vm = this;

    vm.participants = [];
    vm.access_requests = [];
    vm.assessment_users = [];

    vm.hideModal = function() {
      $scope.$emit('close-manage-participants-modal');
    };

    vm.humanPermissionName = function(value) {
      return value === '' ? 'None' : value;
    };

    vm.updateParticipants = function() {
      vm.participants = Participant.all({assessment_id: $stateParams.id});
    };

    vm.updateAssessmentUsers = function() {
      vm.assessment_users = AssessmentPermission.users({assessment_id: $stateParams.id});
    };

    vm.updateAccessRequests = function() {
      vm.access_requests = AssessmentPermission.query({assessment_id: $stateParams.id});
    };

    vm.updateData = function() {
      vm.updateParticipants();
      vm.updateAccessRequests();
      vm.updateAssessmentUsers();
    };

    vm.performPermissionsAction = function(action, id, email) {
      var params = {assessment_id: vm.assessmentId, id: id};

      action(params, {email: email})
          .$promise
          .then(function() {
            vm.updateData();
            $scope.$emit('update_participants');
          });
    };

    vm.denyRequest = function(options) {
      if ($window.confirm('Are you sure you want to deny this access request?')) {
        vm.performPermissionsAction(
            AssessmentPermission.deny,
            options.id,
            options.email);
      }
    };

    vm.acceptRequest = function(options) {
      if ($window.confirm('Are you sure you want to accept this access request?')) {
        vm.performPermissionsAction(
            AssessmentPermission.accept,
            options.id,
            options.email);
      }
    };

    vm.savePermissions = function() {
      var $form = $('#current_user_permissions');
      var permissions = [];

      jQuery.each($form.find('fieldset'), function(i, fieldset) {
        permissions.push({
          email: $(fieldset).find('input[name=email]').val(),
          level: $(fieldset).find('select').val()
        });
      });

      AssessmentPermission.update({
        id: 1,
        assessment_id: $stateParams.id
      }, {permissions: permissions}, function() {
        vm.updateData();
        $scope.$emit('update_participants');
        vm.hideModal();
      });
    };
  }
})();