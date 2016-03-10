PDRClient.directive('responseQuestions', [
  function() {
    return {
      restrict: 'E',
      replace: true,
      scope: {},
      templateUrl: 'client/views/directives/responses/response_questions.html',
      controller: 'ResponseQuestionCtrl'
    };
}]);
