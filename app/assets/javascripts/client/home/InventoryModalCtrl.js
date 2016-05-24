(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InventoryModalCtrl', InventoryModalCtrl);

  InventoryModalCtrl.$inject = [
    '$modalInstance',
    '$timeout',
    '$location',
    'SessionService',
    'RecommendationTextService',
    'Inventory'
  ];

  function InventoryModalCtrl($modalInstance, $timeout, $location, SessionService, RecommendationTextService, Inventory) {
    var vm = this;

    vm.alerts = [];
    vm.user = SessionService.getCurrentUser();
    vm.inventory = {};

    vm.userIsNetworkPartner = function() {
      return SessionService.isNetworkPartner();
    };

    vm.titleText = function() {
      return RecommendationTextService.inventoryText();
    };

    vm.close = function() {
      $modalInstance.close('cancel');
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
          .then(function(response) {
            vm.close();
            $location.url('/inventories/' + response.id + '/assign');
          }, function(response) {
            var errors = response.data.errors;
            angular.forEach(errors, function(error, field) {
              vm.error(field + " : " + error);
            });
          });
    };

    $timeout(function() {
      vm.datetime = $('.datetime').datetimepicker({
        pickTime: false
      });

      vm.datetime.on('dp.change', function() {
        $('#deadline').trigger('change');
      });
    });
  }
})();