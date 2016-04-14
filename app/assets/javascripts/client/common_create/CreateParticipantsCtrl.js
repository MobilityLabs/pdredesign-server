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

    vm.participants = Participant.query({assessment_id: $stateParams.id});
    vm.user = SessionService.getCurrentUser();

    vm.isNetworkPartner = function() {
      return SessionService.isNetworkPartner();
    };

    vm.removeParticipant = function(user) {
      Participant
          .delete({assessment_id: $stateParams.id, id: user.participant_id}, {user_id: user.id})
          .$promise
          .then(function() {
            vm.updateParticipantsList();
          });
    };

    vm.updateParticipantsList = function() {
      Participant.query({assessment_id: $stateParams.id})
          .$promise
          .then(function(data) {
            vm.participants = data;
          }, function() {
            CreateService.emitError('Could not update participants list');
          });

      Participant.all({assessment_id: $stateParams.id})
          .$promise
          .then(function(data) {
            vm.invitableParticipants = data;
          }, function() {
            CreateService.emitError('Could not update participants list');
          });
    };

    $scope.$on('update_participants', function() {
      vm.updateParticipantsList();
    });
  }
})();
