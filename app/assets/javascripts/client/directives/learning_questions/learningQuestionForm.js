(function () {
  'use strict';
  angular.module('PDRClient')
      .directive('learningQuestionForm', learningQuestionForm);

  function learningQuestionForm() {
    return {
      restrict: 'E',
      templateUrl: 'client/views/directives/learning_questions/form.html',
      replace: true,
      controller: 'LearningQuestionFormCtrl',
      controllerAs: 'learningQuestionForm',
      transclude: true
    }
  }
})();