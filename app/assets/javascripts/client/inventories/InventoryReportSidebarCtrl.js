(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryReportSidebarCtrl', InventoryReportSidebarCtrl);

  InventoryReportSidebarCtrl.$inject = [
    '$scope',
    '$modal',
    'inventory'
  ];

  function InventoryReportSidebarCtrl($scope, $modal, inventory) {
    var vm = this;
    $scope.inventory = inventory;
    vm.downloadReport = function() {
      vm.downloadModal = $modal.open({
        templateUrl: 'client/inventories/inventory_report_download_modal.html',
        scope: $scope
      });
    };

    vm.closeDownloadReportModal = function() {
      vm.downloadModal.dismiss();
    };
    $scope.$on('inventory-report-downloaded', function() {
      vm.closeDownloadReportModal();
    });
  }
})();
