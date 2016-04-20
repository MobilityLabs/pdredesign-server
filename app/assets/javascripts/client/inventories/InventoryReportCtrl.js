(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryReportCtrl', InventoryReportCtrl);

  InventoryReportCtrl.$inject = [
    'inventory'
  ];

  function InventoryReportCtrl(inventory) {
    var vm = this;
    vm.inventory = inventory;
  }
})();
