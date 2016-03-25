PDRClient.directive('consensus', [
  function() {
    return {
      restrict: 'E',
      replace: true,
      scope: {
        assessmentId:  '@',
        responseId:    '@',
      },
      templateUrl: 'client/views/directives/response_questions.html',
      controller: [
        '$scope',
        '$http',
        '$timeout',
        '$stateParams',
        '$location',
        'SessionService',
        'Consensus',
        'Score',
        'ResponseHelper',
        function($scope, $http, $timeout, $stateParams, $location, SessionService, Consensus, Score, ResponseHelper) {

          $scope.isConsensus        = true;
          $scope.isReadOnly         = true;
          $scope.teamRole           = null;
          $scope.teamRoles          = [];
          $scope.loading            = false;
          $scope.answerPercentages  = [];

          $scope.isLoading = function(){ return $scope.loading; };

          $scope.toggleCategoryAnswers = function(category) {
            category.toggled = !category.toggled;
            angular.forEach(category.questions, function(question, key) {
              $scope.toggleAnswers(question);
            });
          };

          $scope.questionColor          = ResponseHelper.questionColor;
          $scope.answerCount            = ResponseHelper.answerCount;
          $scope.saveEvidence           = ResponseHelper.saveEvidence;
          $scope.editAnswer             = ResponseHelper.editAnswer;
          $scope.answerTitle            = ResponseHelper.answerTitle;
          $scope.percentageByResponse   = ResponseHelper.percentageByResponse;

          $scope.toggleAnswers = function(question) {
            $scope.$broadcast('question-toggled', question.id);
            ResponseHelper.toggleAnswers(question);
          };

          $scope.assignAnswerToQuestion = function (answer, question) {
            switch(true) {
              case $scope.isReadOnly:
                return false;
              case !question || !question.score:
              case question.score.evidence == null || question.score.evidence == '':
                question.isAlert = true;
                return false;
            }

            ResponseHelper.assignAnswerToQuestion($scope, answer, question);
          };

          $scope.viewModes = [{label: "Category"}, {label: "Variance"}];
          $scope.viewMode  = $scope.viewModes[0];

          $scope.sortByCategory = function() {
            return $scope.data;
          };

          $scope.sortByVariance = function(categories) {
            var tmpObject = {};
            var keys      = [];

            angular.forEach(categories, function(category, _key) {
              angular.forEach(category.questions, function(question, key) {
                if(typeof tmpObject[question.variance] == 'undefined')
                  tmpObject[question.variance] = {"name": question.variance, "questions": []};
                keys.push(question.variance);
                tmpObject[question.variance]["questions"].push(question);
              });
            });

            keys
              .sort()
              .reverse();

            var sorted    = {};
            angular.forEach(keys, function(key) { sorted[key] = tmpObject[key]; });

            return sorted;
          };

          $scope.changeViewMode = function(mode) {
            switch(mode.toLowerCase()) {
              case 'variance':
                $scope.categories = $scope.sortByVariance($scope.data);
                break;
              case 'category':
                $scope.categories = $scope.sortByCategory();
                break;
            }
          };

          $scope.redirectToReport = function(assessmentId) {
            $location.path("/assessments/" + assessmentId + "/report");
          };

          $scope.$on('submit_consensus', function() {
            Consensus
              .submit({assessment_id: $scope.assessmentId, id: $scope.responseId}, {submit: true})
              .$promise
              .then(function(data){
                $scope.redirectToReport($scope.assessmentId);
              });
          });

          $scope.updateConsensus = function(){
             return Consensus
              .get({assessment_id: $scope.assessmentId,
                    id: $scope.responseId,
                    team_role: $scope.teamRole})
              .$promise
              .then(function(data) {
                $scope.scores     = data.scores;
                $scope.data       = data.categories;
                $scope.categories = data.categories;
                $scope.teamRoles  = data.team_roles;
                $scope.isReadOnly = data.is_completed || false;
                $scope.participantCount = data.participant_count;
                return true;
              });
          };

          $scope.updateTeamRole = function(teamRole) {
            if(teamRole.trim() == "") teamRole = null;
            $scope.teamRole = teamRole;

            $scope.loading = true;
            $scope
              .updateConsensus()
              .then(function(){
                $scope.loading = false;
              });
          };

          $timeout(function(){ $scope.updateConsensus(); });

        }]
    };
}]);

PDRClient.filter('scoreFilter', function() {
  return function(input, questionId) {
    var scores = [];
    angular.forEach(input, function(score) {
      if(score.question_id == questionId) scores.push(score);
    });

    return scores;
  };
});
