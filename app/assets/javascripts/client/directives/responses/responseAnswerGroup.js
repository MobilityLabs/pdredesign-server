(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('responseAnswerGroup', responseAnswerGroup);

  function responseAnswerGroup() {
    return {
      restrict: 'E',
      scope: {
        question: '=',
        isConsensus: '@'
      },
      transclude: true,
      replace: true,
      templateUrl: 'client/views/directives/responses/answerGroup.html',
      controller: 'ResponseAnswerGroupCtrl',
      controllerAs: 'responseAnswerGroup'
    }
  }
})();