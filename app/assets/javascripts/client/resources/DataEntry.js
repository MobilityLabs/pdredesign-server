(function() {
  angular.module('PDRClient')
      .factory('DataEntry', DataEntry);

  DataEntry.$inject = [
    '$resource',
    'UrlService'
  ];

  function DataEntry($resource, UrlService) {
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
      }
    };

    return $resource(UrlService.url('inventories/:inventory_id/data_entries/:data_entry_id'), null, methodOptions);
  }
})();
