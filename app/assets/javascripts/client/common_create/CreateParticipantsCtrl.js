(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('CreateParticipantsCtrl', CreateParticipantsCtrl);

  CreateParticipantsCtrl.$inject = [
    '$stateParams',
    '$scope',
    'SessionService',
    'Participant',
    'CreateService'
  ];

  function CreateParticipantsCtrl($stateParams, $scope, SessionService, Participant, CreateService) {
    var vm = this;

    vm.participants = CreateService.loadParticipants();
    vm.user = SessionService.getCurrentUser();

    // Expose context for view
    vm.currentContext = CreateService.context;

    vm.isNetworkPartner = function() {
      return SessionService.isNetworkPartner();
    };

    vm.displayToolType = function() {
      if (CreateService.context === 'assessment') {
        return 'Readiness Assessment';
      } else if (CreateService.context === 'inventory') {
        return 'Data & Tech Inventory';
      }
    };

    vm.removeParticipant = function(user) {
      CreateService.removeParticipant(user)
          .then(function() {
            vm.updateParticipantsList();
          });
    };

    vm.updateParticipantsList = function() {
      CreateService.updateParticipantList()
          .then(function(data) {
            vm.participants = data;
          }, function() {
            CreateService.emitError('Could not update participants list');
          });

      CreateService.updateInvitableParticipantList()
          .then(function(data) {
            vm.invitableParticipants = data;
          }, function() {
            CreateService.emitError('Could not update invitable participants list');
          });
    };

    $scope.$on('update_participants', function() {
      vm.updateParticipantsList();
    });
  }
})();
