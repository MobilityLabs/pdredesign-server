(function() {
  'use strict';

  angular.module('PDRClient').factory('InventoryInvitable', ['$resource', 'UrlService', function($resource, UrlService) {
    return $resource(UrlService.url('inventories/:inventory_id/invitables'), null,{
      list: {
        method: 'GET',
        isArray: true
      }
    });
  }]);
})();
