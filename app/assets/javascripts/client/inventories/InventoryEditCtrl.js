(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryEditCtrl', InventoryEditCtrl);

  InventoryEditCtrl.$inject = [
    'inventory'
  ];

  function InventoryEditCtrl(inventory) {
    var vm = this;
    vm.inventory = inventory;
  }
})();
