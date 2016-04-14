(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('NewParticipantsModalCtrl', NewParticipantsModalCtrl);

  NewParticipantsModalCtrl.$inject = [
    '$scope',
    '$stateParams',
    'Participant'
  ];

  function NewParticipantsModalCtrl($scope, $stateParams, Participant) {
    var vm = this;

    vm.participants = [];

    vm.shouldSendInvite = function() {
      return $scope.sendInvite === 'true';
    };

    vm.hideModal = function() {
      $scope.$emit('close-new-participants-modal');
    };

    vm.updateParticipants = function() {
      vm.participants = Participant.all({assessment_id: $stateParams.id});
    };

    vm.addParticipant = function(user) {
      Participant
          .save({assessment_id: $stateParams.id}, {user_id: user.id, send_invite: vm.shouldSendInvite()})
          .$promise
          .then(function() {
            $scope.$emit('update_participants');
            vm.hideModal();
          });
    };
  }
})();