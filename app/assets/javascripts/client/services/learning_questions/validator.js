(function() {
  'use strict';

  angular.module('PDRClient')
      .service('LearningQuestionValidator', learningQuestionValidator);

  function learningQuestionValidator() {
    var service = this;

    service.validate = function(data) {
      if (!data) {
        return 'Questions may not be empty.';
      } else if (data.length > 255) {
        return 'You may not create a question that exceeds 255 characters in length.'
      }
    };
  }
})();