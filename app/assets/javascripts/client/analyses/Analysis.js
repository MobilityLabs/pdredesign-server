(function() {
  angular.module('PDRClient')
      .factory('Analysis', Analysis);

  Analysis.$inject = [
    '$resource',
    'UrlService'
  ];

  function Analysis($resource, UrlService) {
    var paramDefaults = {
      inventory_id: '@inventory_id'
    };

    var methodOptions = {
      'query': {
        method: 'GET',
        url: UrlService.url('analyses')
      },
      'create': {
        method: 'POST'
      },
      'save': {
        method: 'PUT'
      }
    };

    return $resource(UrlService.url('inventories/:inventory_id/analyses/:id'), paramDefaults, methodOptions);
  }
})();
