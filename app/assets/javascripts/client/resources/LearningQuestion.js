(function() {
  'use strict';
  angular.module('PDRClient')
      .factory('LearningQuestion', ['$resource', 'UrlService', learningQuestionFactory]);

  function learningQuestionFactory($resource, UrlService) {
    var methodOptions = {
      'create': {
        method: 'POST'
      },
      'update': {
        method: 'PATCH',
        params: {
          id: '@id',
          assessment_id: '@assessment_id'
        }
      },
      'exists': {
        method: 'GET',
        url: UrlService.url('assessments/:assessment_id/learning_questions/exists'),
        params: {
          assessment_id: '@assessment_id'
        }
      }
    };
    return $resource(UrlService.url('assessments/:assessment_id/learning_questions/:id'), null, methodOptions);
  }
})();