(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InviteUserCtrl', InviteUserCtrl);

  InviteUserCtrl.$inject = [
    '$scope',
    '$modal'
  ];

  function InviteUserCtrl($scope, $modal) {
    var vm = this;

    vm.showInviteUserModal = function() {
      vm.modalInstance = $modal.open({
        template: '<invite-user-modal send-invite="' + $scope.sendInvite + '" role="' + $scope.role + '"></invite-user-modal>',
        scope: $scope
      });
    };

    $scope.$on('close-invite-modal', function() {
      vm.modalInstance.dismiss('cancel');
    });
  }
})();
