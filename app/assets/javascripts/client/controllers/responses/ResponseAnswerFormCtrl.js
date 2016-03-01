(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ResponseAnswerFormCtrl', ResponseAnswerFormCtrl);

  ResponseAnswerFormCtrl.$inject = [
    '$scope',
    'ResponseHelper'
  ];

  function ResponseAnswerFormCtrl($scope, ResponseHelper) {
    var vm = this;

    vm.invalidEvidence = function(question) {
      return vm.blankable === 'false' && (question.score.evidence === null || question.score.evidence === '');
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