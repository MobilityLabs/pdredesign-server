(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InventoryModalCtrl', InventoryModalCtrl);

  InventoryModalCtrl.$inject = [
    '$scope',
    '$location',
    'SessionService',
    'Inventory'
  ];

  function InventoryModalCtrl($scope, $location, SessionService, Inventory) {
    var vm = this;

    vm.alerts = [];
    vm.user = SessionService.getCurrentUser();
    vm.inventory = {};

    vm.close = function() {
      $scope.$emit('close-inventory-modal');
    };

    vm.error = function(message) {
      vm.alerts.push({type: 'danger', msg: message});
    };

    vm.closeAlert = function(index) {
      vm.alerts.splice(index, 1);
    };

    vm.noDistrict = function() {
      return vm.user === null || (typeof(vm.user.district_ids) === 'undefined' || vm.user.district_ids.length === 0);
    };

    vm.createInventory = function(model) {
      Inventory.create({inventory: model})
          .$promise
          .then(function() {
            vm.close();
            $location.url('/inventories');
          }, function(response) {
            var errors = response.data.errors;
            angular.forEach(errors, function(error, field) {
              vm.error(field + " : " + error);
            });
          });
    }
  }
})();