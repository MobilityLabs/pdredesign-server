(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ResponseAnswerFormCtrl', ResponseAnswerFormCtrl);

  ResponseAnswerFormCtrl.$inject = [
    '$scope',
    'ResponseHelper',
    'ResponseValidationService'
  ];

  function ResponseAnswerFormCtrl($scope, ResponseHelper, ResponseValidationService) {
    var vm = this;

    vm.invalidEvidence = function(question) {
      return ResponseValidationService.invalidEvidence(question, vm.blankable);
    };

    vm.saveEvidence = function(question) {
      if(vm.blankable && question.score.evidence === null) {
        question.score.evidence = '';
      }
      ResponseHelper.saveEvidence(question.score);
    };

    vm.editAnswer = function(question) {
      ResponseHelper.editAnswer(question.score);
    };

    $scope.$watch('blankable', function(val) {
      vm.blankable = val;
    }).bind(vm);
  }
})();