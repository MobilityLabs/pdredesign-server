(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('AnalysisModalCtrl', AnalysisModalCtrl);

  AnalysisModalCtrl.$inject = [
    '$scope',
    '$state',
    '$timeout',
    '$modal',
    '$modalInstance',
    'RecommendationTextService',
    'SessionService',
    'Analysis',
    'Inventory',
    'preSelectedInventory'
  ];

  function AnalysisModalCtrl($scope, $state, $timeout, $modal, $modalInstance, RecommendationTextService, SessionService, Analysis, Inventory, preSelectedInventory) {
    var vm = this;
    vm.analysis = {};
    vm.alerts = [];
    vm.preSelectedInventory = preSelectedInventory;
    if (vm.preSelectedInventory) {
      vm.analysis.inventory_id = vm.preSelectedInventory.id;
    }

    vm.inventories = [];
    vm.hasFetchedInventories = false;

    vm.userIsNetworkPartner = function() {
      return SessionService.isNetworkPartner();
    };

    vm.titleText = function() {
      return RecommendationTextService.analysisText();
    };

    vm.inventoryText = function() {
      return RecommendationTextService.inventoryText();
    };

    vm.closeModal = function() {
      $modalInstance.close('cancel');
    };

    vm.openInventoryModal = function() {
      vm.closeModal('cancel');
      vm.inventoryModal = $modal.open({
        templateUrl: 'client/home/inventory_modal.html',
        controller: 'InventoryModalCtrl',
        controllerAs: 'inventoryModal'
      });
    };

    vm.gotoAnalyses = function() {
      vm.closeModal();
      $state.go('analyses');
    };

    vm.updateData = function() {
      return vm.updateInventories();
    };

    vm.updateInventories = function() {
      return Inventory.query().$promise.then(function(response) {
        vm.inventories = response;

        // ensure an inventory is always selected unless it was pre-selected
        if (!vm.analysis.inventory_id && vm.inventories.length > 0) {
          vm.analysis.inventory_id = vm.inventories[0].id;
        }

        vm.hasFetchedInventories = true;
      });
    };

    vm.addAlert = function(message) {
      vm.alerts.push({type: 'danger', msg: message});
    };

    vm.closeAlert = function(index) {
      vm.alerts.splice(index, 1);
    };

    vm.hasInventories = function() {
      return vm.hasFetchedInventories && _.any(vm.inventories);
    };

    vm.hasNoInventories = function() {
      return vm.hasFetchedInventories && _.isEmpty(vm.inventories);
    };

    vm.save = function() {
      var deadlineFromDOM = $('#analysis-deadline').val();
      vm.analysis.deadline = moment(deadlineFromDOM, 'MM/DD/YYYY', true).toISOString();
      Analysis.create(null, vm.analysis)
          .$promise
          .then(function(productEntry) {
            vm.closeModal();
            $state.go('inventory_analysis_assign', {inventory_id: productEntry.inventory_id, id: productEntry.id});
          }, function(response) {
            var errors = response.data.errors;
            angular.forEach(errors, function(error, field) {
              vm.addAlert(field + " : " + error);
            });
          });
    };

    $timeout(function() {
      vm.datetime = $('.datetime').datetimepicker({
        pickTime: false
      });

      vm.datetime.on('dp.change', function() {
        vm.datetime.find('input').trigger('change');
      });

      vm.updateData();
    });

    vm.defaultDate = function(model) {
      if (typeof(model) !== 'undefined') {
        return moment(model.due_date || model.deadline).format('MM/DD/YYYY');
      }
    };

    $scope.$watch('vm.analysis', function(val) {
      vm.date = vm.defaultDate(val);
    }).bind(vm);
  }
})();
