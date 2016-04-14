(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InviteUserModalCtrl', InviteUserModalCtrl);

  InviteUserModalCtrl.$inject = [
    '$scope',
    '$stateParams',
    'UserInvitation'
  ];

  function InviteUserModalCtrl($scope, $stateParams, UserInvitation) {
    var vm = this;

    vm.alerts = [];

    vm.addAlert = function(message) {
      vm.alerts.push({type: 'danger', msg: message});
    };

    vm.closeAlert = function(index) {
      vm.alerts.splice(index, 1);
    };

    vm.shouldSendInvite = function() {
      return $scope.sendInvite === 'true';
    };

    vm.closeModal = function() {
      $scope.$emit('close-invite-modal');
    };

    vm.createInvitation = function(userObject) {
      if (vm.shouldSendInvite()) {
        userObject['send_invite'] = true;
      }

      UserInvitation
          .create({assessment_id: $stateParams.id}, userObject)
          .$promise
          .then(function() {
            $scope.$emit('update_participants');
            vm.closeModal();
          }, function(response) {
            var errors = response.data.errors;
            angular.forEach(errors, function(error, field) {
              vm.addAlert(field + " : " + error);
            });
          });
    };
  }
})();