(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('LearningQuestionListDisplayCtrl', LearningQuestionListDisplayCtrl);

  LearningQuestionListDisplayCtrl.$inject = [
    '$stateParams',
    '$scope',
    '$window',
    'LearningQuestion',
    'LearningQuestionValidator'
  ];

  function LearningQuestionListDisplayCtrl($stateParams, $scope, $window, LearningQuestion, LearningQuestionValidator) {
    var vm = this;
    vm.learningQuestions = [];

    vm.extractId = function() {
      return $stateParams.assessment_id || $stateParams.id;
    };

    vm.loadQuestions = function() {
      LearningQuestion
          .get({assessment_id: vm.extractId()})
          .$promise
          .then(function(result) {
            vm.learningQuestions = result.learning_questions;
          });
    };

    vm.deleteLearningQuestion = function(model) {
      if (!model.editable) {
        return;
      }
      var willDelete = $window.confirm('Are you sure you wish to delete this learning question?');
      if (willDelete) {
        LearningQuestion
            .delete({assessment_id: vm.extractId(), id: model.id})
            .$promise
            .then(function() {
              $scope.$emit('learning-question-change');
            });
      }
    };

    vm.updateLearningQuestion = function(model) {
      if (model.editable) {
        LearningQuestion
            .update({assessment_id: vm.extractId(), id: model.id, learning_question: {body: model.body}})
            .$promise
            .then(function() {
              $scope.$emit('learning-question-change');
            }).catch(function() {
          $scope.$emit('learning-question-change');
        });
      }
    };

    vm.validate = function(data) {
      return LearningQuestionValidator.validate(data);
    };

    $scope.$on('learning-question-change', function() {
      vm.loadQuestions();
    });

    vm.loadQuestions();
  }
})();