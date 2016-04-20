(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('inventoryDataEntries', inventoryDataEntries);

  function inventoryDataEntries() {
    return {
      restrict: 'E',
      scope: {
        inventory: '=',
        readOnly: '='
      },
      templateUrl: 'client/inventories/inventory_data_entries.html',
      controller: 'InventoryDataEntriesCtrl',
      controllerAs: 'inventoryDataEntries',
      replace: true
    }
  }
})();
