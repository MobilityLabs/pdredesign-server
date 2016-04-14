(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('StartInventoryCtrl', StartInventoryCtrl);

  StartInventoryCtrl.$inject = [
    '$modal',
    '$scope'
  ];

  function StartInventoryCtrl($modal, $scope) {
    var vm = this;

    vm.openInventoryModal = function() {
      vm.modal = $modal.open({
        template: '<inventory-modal></inventory-modal>',
        scope: $scope
      })
    };

    $scope.$on('close-inventory-modal', function() {
      vm.modal.close('cancel');
    });
  }
})();