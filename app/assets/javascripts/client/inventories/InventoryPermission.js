(function() {
  'use strict';

  angular.module('PDRClient').factory('InventoryPermission', InventoryPermission);

  InventoryPermission.$inject = [
    '$resource',
    'UrlService'
  ];

  function InventoryPermission($resource, UrlService) {
    var options = {
      list: {
        method: 'GET',
        isArray: true
      },
      update: {
        method: 'PATCH',
      }
    };
    return $resource(UrlService.url('inventories/:inventory_id/permissions'), null, options);
  }
})();
