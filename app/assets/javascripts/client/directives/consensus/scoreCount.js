(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('scoreCount', scoreCount);

  function scoreCount() {
    return {
      restrict: 'E',
      transclude: true,
      replace: true,
      scope: {
        question: '=',
        answer: '='
      },
      templateUrl: 'client/views/directives/consensus/score_count.html',
      controller: 'ScoreCountCtrl',
      controllerAs: 'scoreCount'
    }
  }
})();