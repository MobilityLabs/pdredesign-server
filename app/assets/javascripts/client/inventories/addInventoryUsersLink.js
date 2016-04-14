(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('addInventoryUsersLink', addInventoryUsersLink);

  function addInventoryUsersLink() {
    return {
      restrict: 'E',
      scope: {
        inventoryId: '=inventoryId'
      },
      templateUrl: 'client/inventories/add_inventory_users_link.html',
      controller: 'AddInventoryUsersLinkCtrl',
      controllerAs: 'inventoryUsersLink',
      replace: true
    }
  }
})();
