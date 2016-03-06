(function() {
  'use strict';

  angular.module('PDRClient')
      .service('ResponseValidationService', ResponseValidationService);

  function ResponseValidationService() {
    this.invalidEvidence = function(question, blankable) {
      if(!(question && question.score)) {
        return;
      }
      return blankable === 'false' && (question.score.evidence === null || question.score.evidence === '');
    }
  }
})();