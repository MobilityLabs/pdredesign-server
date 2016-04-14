(function() {
  'use strict';
  angular.module('PDRClient').controller('ManageInventoryPermissionsCtrl', ManageInventoryPermissionsCtrl); 

  ManageInventoryPermissionsCtrl.$inject = ['$scope', 'InventoryPermission'];

  function ManageInventoryPermissionsCtrl($scope, InventoryPermission) {
    var vm = this;
    vm.loadList = function() {
      vm.list = InventoryPermission.list({inventory_id: $scope.inventoryId});
    };
    vm.loadList();

    vm.extractInputValues = function() {
      var $form = $('#current_user_permissions');
      var permissions = [];

      jQuery.each($form.find('fieldset'), function( i, fieldset ) {
        permissions.push({
          email: $(fieldset).find('input[name=email]').val(),
          role: $(fieldset).find('select').val()
        });
      });
      return permissions;
    };

    $scope.$on('save', function() {
      vm.savePermissions(vm.extractInputValues());
    });

    vm.savePermissions = function(permissions){
      InventoryPermission.update({
        inventory_id: $scope.inventoryId
      }, { permissions: permissions }, function() {
        $scope.$emit('close-modal');
      });
    };
  }
})();
