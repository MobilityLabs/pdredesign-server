(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InventorySidebarCtrl', InventorySidebarCtrl);

  InventorySidebarCtrl.$inject = [
    'inventory'
  ];

  function InventorySidebarCtrl(inventory) {
  }
})();