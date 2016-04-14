(function() {
  'use strict';
  angular.module('PDRClient')
      .service('ResponseHelper', ResponseHelper);

  ResponseHelper.$inject = [
    'Score',
    '$modal'
  ];

  function ResponseHelper(Score, $modal) {
    var scope = this;

    this.answerCount = function(scores, questionId, answerValue) {
      var count = 0;
      angular.forEach(scores, function(score) {
        if (score.question_id !== questionId) {
          return false;
        }

        if (score.value === answerValue) {
          count++;
        }
      });
      return count;
    };

    this.toggleCategoryAnswers = function(question) {
      question.answersVisible = !question.answersVisible;
    };

    this.toggleAnswers = function(question, $event) {
      var target = $event.target;
      if (target.id === 'question-' + question.id
          || target.classList.contains('question-headline')
          || target.classList.contains('content')) {
        question.answersVisible = !question.answersVisible;
      }
    };

    this.answerTitle = function(value) {
      switch (value) {
        case 1:
          return 'Non-Existent';
        case 2:
          return 'Initial';
        case 3:
          return 'Defined & Managed';
        case 4:
          return 'Optimizing';
      }
    };

    this.saveEvidence = function(score) {
      score.editMode = true;
    };

    this.editAnswer = function(score) {
      score.editMode = false;
    };

    this.skipped = function(question) {
      switch (true) {
        case !question || !question.score:
          return false;
        case question.skipped:
        case question.score.value == null && question.score.evidence != null:
          return true;
        default:
          return false;
      }
    };

    this.saveRetry = function(scopeObject, answer, question) {

      scopeObject.cancel = function() {
        return confirmModal.dismiss('cancel');
      };

      //scopeObject resubmit function for ng-click in $modal
      scopeObject.retryScorePost = function() {
        scopeObject.cancel();
        return scope.assignAnswerToQuestion(scopeObject, answer, question);
      };

      var confirmModal = $modal.open({
        templateUrl: 'client/views/modals/save_retry.html',
        scope: scopeObject
      });
    };

    this.assignAnswerToQuestion = function(scopeObject, answer, question) {
      var params = {response_id: scopeObject.responseId, assessment_id: scopeObject.assessmentId};
      var score = {question_id: question.id, value: answer.value, evidence: question.score.evidence};

      question.loading = true;

      Score
          .save(params, score)
          .$promise
          .then(function() {
            scopeObject.$emit('response_updated');
            question.loading = false;
            question.isAlert = false;
            question.score.value = answer.value;
          }, function() {
            scope.saveRetry(scopeObject, answer, question);
          });
    };

    this.questionColor = function(question, isConsensus) {
      if (!question.score) {
        return null;
      }

      if (!isConsensus) {
        if (question.score.evidence != null && question.score.value == null)
          return "scored-skipped";
      }

      return 'scored-' + question.score.value;
    };

    this.percentageByResponse = function(scores, questionId, answerValue, totalParticipants) {
      var numberOfAnswers = scope.answerCount(scores, questionId, answerValue);
      return ((numberOfAnswers * 100) / totalParticipants) + '%';
    };
  }
})();
