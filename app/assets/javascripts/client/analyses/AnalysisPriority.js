(function() {
  'use strict';

  angular.module('PDRClient')
      .factory('AnalysisPriority', AnalysisPriority);

  AnalysisPriority.$inject = [
    '$resource',
    'UrlService'
  ];

  function AnalysisPriority($resource, UrlService) {
    return $resource(UrlService.url('inventories/:inventory_id/analyses/:id/analysis_priorities'));
  }
})();