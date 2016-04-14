(function() {
  'use strict';
  angular.module('PDRClient').controller('AddInventoryUsersLinkCtrl', AddInventoryUsersLinkCtrl); 
  AddInventoryUsersLinkCtrl.$inject = ['$modal', '$scope', 'InventoryInvitable'];
  function AddInventoryUsersLinkCtrl($modal, $scope, InventoryInvitable) {
    var vm = this;
    vm.open = function() {
      vm.modal = $modal.open({
        templateUrl: 'client/inventories/add_inventory_users_modal.html',
        scope: $scope,
        windowClass: 'request-access-window'
      });
    };
    vm.close = function() {
      vm.modal.dismiss();
    };

    vm.loadInvitables = function() {
      vm.invitables = InventoryInvitable.list({ inventory_id: $scope.inventoryId });
    };
    vm.invitablesFound = function() {
      var list = vm.invitables;
      return list && list.length > 0;
    };
    vm.loadInvitables();
  }
})();
