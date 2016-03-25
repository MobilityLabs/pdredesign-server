(function() {
  'use strict';

  angular.module('PDRClient')
      .factory('Consensus', Consensus);

  Consensus.$inject = [
    '$resource',
    'UrlService'
  ];

  function Consensus($resource, UrlService) {
    return $resource(UrlService.url('assessments/:assessment_id/consensus/:id'), null,
        {
          'get': {method: 'GET', cache: true},
          'create': {method: 'POST'},
          'submit': {method: 'PUT'},
          'evidence': {
            method: 'GET',
            url: UrlService.url('assessments/:assessment_id/evidence/:question_id'),
            params: {
              assessment_id: '@assessment_id',
              question_id: '@question_id'
            },
            isArray: true
          },
          'pdf_report': {
            url: UrlService.url('assessments/:assessment_id/reports/consensus_report.pdf'),
            action: 'consensus_report'
          },
          'report': {
            url: UrlService.url('assessments/:assessment_id/consensus/:id/consensus_report'),
            action: 'consensus_report'
          }
        });
  }
})();
