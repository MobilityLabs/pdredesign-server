(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('responseAnswerForm', responseAnswerForm);

  function responseAnswerForm() {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        question: '=',
        answer: '=',
        blankable: '@',
        visible: '@',
        placeholder: '@'
      },
      replace: true,
      templateUrl: 'client/views/directives/responses/form.html',
      controller: 'ResponseAnswerFormCtrl',
      controllerAs: 'responseAnswerForm'
    }
  }
})();