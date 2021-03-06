(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryReportSidebarCtrl', InventoryReportSidebarCtrl);

  InventoryReportSidebarCtrl.$inject = [
    '$scope',
    '$modal',
    'inventory',
    '$stateParams',
    '$state'
  ];

  function InventoryReportSidebarCtrl($scope, $modal, inventory, $stateParams, $state) {
    var vm = this;

    vm.inventory = inventory;
    vm.shared = $stateParams.shared || false;
    vm.hideAnalysisAccess = vm.inventory.analysis_count === 0 && !vm.inventory.is_facilitator_or_participant;
    vm.creatingAnalysis = vm.inventory.analysis_count === 0 && vm.inventory.is_facilitator_or_participant;
    vm.shareURL = $state.href(
      'inventories_shared_report',
      {inventory_id: vm.inventory.share_token},
      {absolute: true}
    );

    vm.createAnalysis = function() {
      vm.analysisModal = $modal.open({
        templateUrl: 'client/analyses/analysis_modal.html',
        controller: 'AnalysisModalCtrl',
        controllerAs: 'analysisModal',
        resolve: {
          preSelectedInventory: function() {
            return vm.inventory;
          }
        }
      });
    };

    vm.goToAnalysis = function() {
      if (vm.inventory.analysis_count === 1) {
        var analysisState = !vm.inventory.analysis.assigned_at ? 'inventory_analysis_dashboard' : 'inventory_analysis_report';
        $state.go(analysisState, {
          inventory_id: vm.inventory.id,
          analysis_id: vm.inventory.analysis.id
        });
      } else {
        $state.go('analyses');
      }
    };

    vm.downloadReport = function() {
      vm.downloadModal = $modal.open({
        templateUrl: 'client/inventories/inventory_report_download_modal.html',
        scope: $scope
      });
    };

    vm.closeDownloadReportModal = function() {
      vm.downloadModal.dismiss();
    };

    vm.displayLearningQuestions = function() {
      vm.modal = $modal.open({
        template: '<learning-question-modal context="inventory" reminder="false"></learning-question-modal>',
        scope: $scope
      });
    };

    $scope.$on('close-learning-question-modal', function() {
      vm.modal.dismiss('cancel');
    });

    $scope.$on('inventory-report-downloaded', function() {
      vm.closeDownloadReportModal();
    });
  }
})();
