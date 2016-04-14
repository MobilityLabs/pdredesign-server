(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('startInventory', startInventory);

  function startInventory() {
    return {
      restrict: 'E',
      transclude: true,
      scope: {},
      replace: true,
      templateUrl: 'client/home/start_inventory.html',
      controller: 'StartInventoryCtrl',
      controllerAs: 'startInventory'
    }
  }
})();