(function() {
  'use strict';

  angular.module('PDRClient')
      .factory('Inventory', Inventory);

  Inventory.$inject = [
    '$resource',
    'UrlService'
  ];

  function Inventory($resource, UrlService) {
    var methodOptions = {
      'query': {
        method: 'GET',
        isArray: false
      },
      'create': {
        method: 'POST'
      }
    };

    return $resource(UrlService.url('inventories/:inventory_id'), null, methodOptions);
  }
})();
