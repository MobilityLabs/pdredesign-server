(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryIndexCtrl', InventoryIndexCtrl);

  InventoryIndexCtrl.$inject = [
    'SessionService',
    'inventory_result'
  ];

  function InventoryIndexCtrl(SessionService, inventory_result) {
    var vm = this;

    vm.user = SessionService.getCurrentUser();
    vm.inventories = inventory_result.inventories;

  }
})();