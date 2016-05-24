(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('inventoryProductEntries', inventoryProductEntries);

  function inventoryProductEntries() {
    return {
      restrict: 'E',
      scope: {
        inventory: '=',
        readOnly: '=',
        shared: '='
      },
      templateUrl: 'client/inventories/inventory_product_entries.html',
      controller: 'InventoryProductEntriesCtrl',
      controllerAs: 'inventoryProductEntries',
      replace: true
    }
  }
})();
