(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('manageInventoryPermissionsLink', manageInventoryPermissionsLink);

  function manageInventoryPermissionsLink() {
    return {
      restrict: 'E',
      scope: {
        inventoryId: '='
      },
      templateUrl: 'client/inventories/manage_inventory_permissions_link.html',
      controller: 'ManageInventoryPermissionsLinkCtrl',
      controllerAs: 'manageInventoryPermissionsLink',
      replace: true
    }
  }
})();
