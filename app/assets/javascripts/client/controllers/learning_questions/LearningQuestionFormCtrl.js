(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('LearningQuestionFormCtrl', LearningQuestionFormCtrl);

  LearningQuestionFormCtrl.$inject = [
    '$stateParams',
    '$scope',
    'LearningQuestion',
    'LearningQuestionValidator'
  ];

  function LearningQuestionFormCtrl($stateParams, $scope, LearningQuestion, LearningQuestionValidator) {
    var vm = this;
    vm.error = '';
    vm.newEntity = {
      'body': ''
    };

    vm.extractId = function() {
      return $stateParams.assessment_id || $stateParams.id;
    };

    vm.clearInputForm = function(model) {
      model.body = '';
    };

    vm.createLearningQuestion = function(model) {
      var validationMsg = vm.validate(model.body);
      if(validationMsg) {
        vm.error = validationMsg;
        $scope.learningQuestionForm.$invalid = true;
      } else {
        $scope.learningQuestionForm.$invalid = false;
        LearningQuestion
            .create({assessment_id: vm.extractId()}, {learning_question: {body: model.body}})
            .$promise
            .then(function() {
              $scope.$emit('learning-question-change');
              vm.clearInputForm(model);
            });
      }
    };

    vm.validate = function(data) {
      return LearningQuestionValidator.validate(data);
    }
  }
})();