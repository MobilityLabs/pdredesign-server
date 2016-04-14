(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('AddNewParticipantsCtrl', AddNewParticipantsCtrl);

  AddNewParticipantsCtrl.$inject = [
    '$scope',
    '$modal'
  ];

  function AddNewParticipantsCtrl($scope, $modal) {
    var vm = this;

    vm.showNewParticipantsModal = function() {
      vm.newParticipantsModal = $modal.open({
        template: '<new-participants-modal send-invite="' + $scope.sendInvite + '"></new-participants-modal>',
        scope: $scope,
        size: 'lg'
      });
    };

    $scope.$on('close-new-participants-modal', function() {
      vm.newParticipantsModal.dismiss('cancel');
    });
  }
})();