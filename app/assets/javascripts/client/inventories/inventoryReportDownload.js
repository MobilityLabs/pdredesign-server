(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('inventoryReportDownload', inventoryReportDownload);

  function inventoryReportDownload() {
    return {
      restrict: 'E',
      scope: {
        inventory: '='
      },
      templateUrl: 'client/inventories/inventory_report_download.html',
      controller: 'InventoryReportDownloadCtrl',
      controllerAs: 'inventoryReportDownload',
      replace: true
    }
  }
})();
