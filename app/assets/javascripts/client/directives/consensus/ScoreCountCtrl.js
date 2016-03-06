(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ScoreCountCtrl', ScoreCountCtrl);

  ScoreCountCtrl.$inject = [
    'ConsensusStateService',
    'ResponseHelper'
  ];

  function ScoreCountCtrl(ConsensusStateService, ResponseHelper) {
    var vm = this;

    vm.consensus = ConsensusStateService.getConsensusData();

    vm.answerCount = function(scores, questionId, answerValue) {
      return ResponseHelper.answerCount(scores, questionId, answerValue);
    };
  }
})();