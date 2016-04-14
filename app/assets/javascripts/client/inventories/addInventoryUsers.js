(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('addInventoryUsers', addInventoryUsers);

  function addInventoryUsers() {
    return {
      restrict: 'E',
      scope: {
        inventoryId: '=inventoryId'
      },
      templateUrl: 'client/inventories/add_inventory_users.html',
      controller: 'AddInventoryUsersCtrl',
      controllerAs: 'addInventoryUsers',
      replace: true
    }
  }
})();
