(function() {
  'use strict';
  angular.module('PDRClient').controller('InventoryReportDownloadCtrl', InventoryReportDownloadCtrl);

  InventoryReportDownloadCtrl.$inject = ['$scope', 'UrlService'];

  function InventoryReportDownloadCtrl($scope, UrlService) {
    var vm = this;
    vm.inventory = $scope.inventory;
    vm.download = function() {
      if(vm.downloadOptions.productEntries) {
        var link = angular.element('<a/>');
        link.attr({
          href: UrlService.url('/inventories/' + vm.inventory.id + '/product_entries.csv'),
          target: '_blank',
          download: 'inventory_' + vm.inventory.id + '_product_entries_report.csv'
        })[0].click();
      }
      if(vm.downloadOptions.dataEntries) {
        var link = angular.element('<a/>');
        link.attr({
          href: UrlService.url('/inventories/' + vm.inventory.id + '/data_entries.csv'),
          target: '_blank',
          download: 'inventory_' + vm.inventory.id + '_data_entries_report.csv'
        })[0].click();
      }
      $scope.$emit('inventory-report-downloaded');
    };
  }
})();
