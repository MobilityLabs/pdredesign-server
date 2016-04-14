(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ManageParticipantsCtrl', ManageParticipantsCtrl);

  ManageParticipantsCtrl.$inject = [
    '$scope',
    '$modal'
  ];

  function ManageParticipantsCtrl($scope, $modal) {
    var vm = this;

    vm.showAddParticipants = function() {
      vm.modalInstance = $modal.open({
        template: '<manage-participants-modal></manage-participants-modal>',
        scope: $scope,
        size: 'lg'
      });
    };

    vm.hideModal = function() {
      vm.modalInstance.dismiss('cancel');
    };

    $scope.$on('close-manage-participants-modal', function() {
      vm.hideModal();
    });
  }
})();
