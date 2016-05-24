(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('AnalysisSidebarCtrl', AnalysisSidebarCtrl);

  AnalysisSidebarCtrl.$inject = [
    'current_analysis',
    '$scope',
    '$modal'
  ];

  function AnalysisSidebarCtrl(current_analysis, $scope, $modal) {
    var vm = this;
    $scope.analysis = current_analysis;
    vm.currentAnalysis = current_analysis;

    vm.goToAssign = current_analysis.assigned_at === null;
    vm.goToConsensus = current_analysis.consensus && current_analysis.consensus.is_completed === false;
    vm.goToReport = current_analysis.consensus && current_analysis.consensus.is_completed === true;

    vm.displayLearningQuestions = function() {
      vm.questionsModal = $modal.open({
        template: '<learning-question-modal context="analysis" reminder="false"></learning-question-modal>',
        scope: $scope
      });
    };

    vm.modifyCalendar = function () {
      vm.deadlineModal = $modal.open({
        template: '<analysis-deadline-modal analysis="analysis"></analysis-deadline-modal>',
        scope: $scope
      });
    };

    $scope.$on('close-deadline-modal', function() {
      vm.deadlineModal.dismiss('cancel');
    });

    $scope.$on('close-learning-question-modal', function() {
      vm.questionsModal.dismiss('cancel');
    });
  }
})();
