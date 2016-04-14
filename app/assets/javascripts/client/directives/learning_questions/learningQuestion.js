(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('learningQuestion', learningQuestion);

  function learningQuestion() {
    return {
      restrict: 'E',
      scope: {
        'modal': '@'
      },
      templateUrl: 'client/views/directives/learning_questions/display.html',
      replace: true,
      transclude: true
    }
  }
})();
