(function() {
  angular.module('PDRClient')
      .factory('ProductEntry', ProductEntry);

  ProductEntry.$inject = [
    '$resource',
    'UrlService'
  ];

  function ProductEntry($resource, UrlService) {
    var methodOptions = {
      'get': {
        method: 'GET',
        isArray: false
      },
      'create': {
        method: 'POST'
      },
      'update': {
        method: 'PUT'
      },
      'restore': {
        method: 'PUT',
        url: UrlService.url('inventories/:inventory_id/product_entries/:product_entry_id/restore')
      }
    };

    return $resource(UrlService.url('inventories/:inventory_id/product_entries/:product_entry_id'), null, methodOptions);
  }
})();
