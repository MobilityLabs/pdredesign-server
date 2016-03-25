(function() {
  'use strict';

  angular.module('PDRClient')
      .factory('Response', Response);

  Response.$inject = [
    '$resource',
    'UrlService'
  ];

  function Response($resource, UrlService) {
    return $resource(UrlService.url('assessments/:assessment_id/responses/:id'), null, {
      'get': {
        method: 'GET',
        url: UrlService.url('assessments/:assessment_id/responses/:id/slim')
      },

      'submit': {method: 'PUT'}
    });
  }
})();
