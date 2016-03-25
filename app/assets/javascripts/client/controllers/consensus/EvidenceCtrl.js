(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('EvidenceCtrl', EvidenceCtrl);

  EvidenceCtrl.$inject = [
    '$scope',
    '$stateParams',
    'Consensus'
  ];

  function EvidenceCtrl($scope, $stateParams, Consensus) {
    var vm = this;

    vm.hasLoadedContent = false;

    vm.scoreValue = function(score) {
      if (!score || score <= 0) {
        return 'S';
      }
      return '' + score;
    };

    vm.scoreClass = function(score) {
      if (!score || score <= 0) {
        return 'skipped';
      }
      return 'scored-' + score;
    };

    vm.loadResponses = function() {
      Consensus.evidence({
        assessment_id: $stateParams.assessment_id,
        question_id: vm.questionId
      }).$promise
          .then(function(data) {
            vm.responses = data;
          });
    };

    $scope.$watch('questionId', function(val) {
      vm.questionId = val;
    }).bind(vm);

    $scope.$on('question-toggled', function(event, val) {
      if (parseInt(vm.questionId) === parseInt(val) && !vm.hasLoadedContent) {
        vm.loadResponses();
        vm.hasLoadedContent = !vm.hasLoadedContent;
      }
    });
  }
})();
