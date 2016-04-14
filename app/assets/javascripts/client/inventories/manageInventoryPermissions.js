(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('manageInventoryPermissions', manageInventoryPermissions);

  function manageInventoryPermissions() {
    return {
      restrict: 'E',
      scope: {
        inventoryId: '='
      },
      templateUrl: 'client/inventories/manage_inventory_permissions.html',
      controller: 'ManageInventoryPermissionsCtrl',
      controllerAs: 'manageInventoryPermissions',
      replace: true
    }
  }
})();
