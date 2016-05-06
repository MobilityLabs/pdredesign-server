PDRClient.directive('consensus', [
  function() {
    return {
      restrict: 'E',
      replace: true,
      scope: {
        assessmentId:  '@',
        responseId:    '@',
        entity:        '=',
        consensus:     '='
      },
      templateUrl: 'client/views/directives/consensus/consensus_questions.html',
      controller: [
        '$scope',
        '$timeout',
        '$location',
        'Consensus',
        'Score',
        'ResponseHelper',
        'ConsensusStateService',
        'ConsensusService',
        function($scope, $timeout, $location, Consensus, Score, ResponseHelper, ConsensusStateService, ConsensusService) {

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
              ResponseHelper.toggleCategoryAnswers(question);
            });
          };

          $scope.toggleAnswers = function(question, $event) {
            ResponseHelper.toggleAnswers(question, $event);
          };

          $scope.questionColor          = ResponseHelper.questionColor;
          $scope.answerCount            = ResponseHelper.answerCount;
          $scope.saveEvidence           = ResponseHelper.saveEvidence;
          $scope.editAnswer             = ResponseHelper.editAnswer;
          $scope.answerTitle            = ResponseHelper.answerTitle;
          $scope.percentageByResponse   = ResponseHelper.percentageByResponse;

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

          $scope.redirectToReport = function(assessmentId) {
            $location.path("/assessments/" + assessmentId + "/report");
          };

          $scope.$on('submit_consensus', function() {
            ConsensusService
              .submitConsensus($scope.consensus.id)
              .then(function (data) {
                $scope.redirectToReport($scope.assessmentId);
              });
          });

          $scope.updateConsensus = function(){
            return ConsensusService
              .loadConsensus($scope.consensus.id, $scope.teamRole)
              .then(function (data) {
                $scope.scores     = data.scores;
                $scope.data       = data.categories;
                $scope.categories = data.categories;
                $scope.teamRoles  = data.team_roles;
                $scope.isReadOnly = data.is_completed || false;
                $scope.participantCount = data.participant_count;
              });
          };

          $scope.updateConsensusState = function(data) {
            ConsensusStateService.addConsensusData(data);
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

          $scope.scoreValue = function(score) {
            if(!score || score <= 0)
              return "S";
            return "" + score;
          };

          $scope.scoreClass = function(score) {
            if(!score || score <= 0)
              return "skipped";
            return "scored-" + score;
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
