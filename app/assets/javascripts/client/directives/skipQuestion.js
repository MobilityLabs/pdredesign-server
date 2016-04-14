PDRClient.directive('skipQuestion', [
  function() {
    return {
      restrict: 'E',
      replace: true,
      scope: {
        question: "=",
        editable: "=",
        responseId: "@",
        assessmentId: "@"
      },
      templateUrl: 'client/views/shared/responses/skip_question.html',
      controller: [
        '$scope',
        '$timeout',
        'ResponseHelper',
        function($scope, $timeout, ResponseHelper) {
          $scope.editAnswer = ResponseHelper.editAnswer;

          $scope.skipped    = function(question) {
            if(!$scope.editable) return;
            return ResponseHelper.skipped(question);
          };

          $scope.skipQuestion = function(question, score) {
            if(!$scope.editable) return;
            question.skipped = true;

            var answer = { value: null };
            ResponseHelper.assignAnswerToQuestion($scope, answer, question);
          };

          $scope.skipQuestionSaveEvidence = function(score){
            if(!$scope.editable) return;
            if(score.evidence == null)
              score.evidence = '';
            score.editMode = true;
          };

        }]
    };
}]);
