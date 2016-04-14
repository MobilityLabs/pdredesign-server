(function() {
  'use strict';
  angular.module('PDRClient').controller('ManageInventoryPermissionsModalCtrl', ManageInventoryPermissionsModalCtrl); 
  ManageInventoryPermissionsModalCtrl.$inject = ['$modal', '$scope'];
  function ManageInventoryPermissionsModalCtrl($modal, $scope) {
    var vm = this;
    vm.assessment_users = [];
    vm.open = function() {
      vm.modal = $modal.open({
        templateUrl: 'client/inventories/manage_inventory_permissions_modal.html',
        scope: $scope,
        windowClass: 'request-access-window'
      });
    };
    vm.close = function() {
      vm.modal.dismiss();
    };
  }
})();
