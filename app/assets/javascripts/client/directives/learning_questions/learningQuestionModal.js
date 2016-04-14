(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('learningQuestionModal', learningQuestionModal);

  function learningQuestionModal() {
    return {
      restrict: 'E',
      scope: {
        reminder: '@'
      },
      templateUrl: 'client/views/modals/learning_questions/add_learning_question.html',
      link: function(scope) {
        scope.closeModal = function() {
          scope.$emit('close-learning-question-modal');
        }
      },
      replace: true,
      transclude: true
    }
  }
})();
