(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InventoryEditSidebarCtrl', InventoryEditSidebarCtrl);

  InventoryEditSidebarCtrl.$inject = [
    '$modal',
    '$scope',
    '$stateParams',
    '$state',
    'Inventory'
  ];

  function InventoryEditSidebarCtrl($modal, $scope, $stateParams, $state, Inventory) {
    var vm = this;

    vm.displayLearningQuestions = function() {
      vm.modal = $modal.open({
        template: '<learning-question-modal context="inventory" reminder="false"></learning-question-modal>',
        scope: $scope
      });
    };

    vm.saveInventoryResponse = function() {
      Inventory.saveResponse({inventory_id: $stateParams.inventory_id})
          .$promise
          .then(function() {
            $state.transitionTo('inventory_dashboard', {
              inventory_id: $stateParams.inventory_id
            });
          });
    };

    $scope.$on('close-learning-question-modal', function() {
      vm.modal.dismiss('cancel');
    });

  }
})();