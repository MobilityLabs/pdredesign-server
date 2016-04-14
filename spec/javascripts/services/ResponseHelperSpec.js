(function() {
  'use strict';
  describe('Service: ResponseHelper', function() {
    var subject,
        scope,
        $httpBackend,
        $modal,
        $q;

    beforeEach(function() {
      module('PDRClient');
      inject(function($rootScope, $compile, $timeout, _$q_, ResponseHelper, $injector) {
        subject = ResponseHelper;
        $q = _$q_;
        scope = $rootScope.$new(true);
        $modal = $injector.get('$modal');
        $httpBackend = $injector.get('$httpBackend');
      });
    });

    it('editAnswer will set score.editMode to false', function() {
      var score = {editMode: true};
      subject.editAnswer(score);
      expect(score.editMode).toEqual(false);
    });

    it('saveEvidence will set score.editMode to true', function() {
      var score = {editMode: false};
      subject.saveEvidence(score);
      expect(score.editMode).toEqual(true);
    });

    describe('#answerCount', function() {
      var scores = [{question_id: 1, value: 1},
        {question_id: 2, value: 4},
        {question_id: 1, value: 4},
        {question_id: 1, value: 4}];

      it('return the count for a question id and answer id', function() {
        expect(subject.answerCount(scores, 1, 4)).toEqual(2);
        expect(subject.answerCount(scores, 1, 1)).toEqual(1);
        expect(subject.answerCount(scores, 1, 0)).toEqual(0);
        expect(subject.answerCount(scores, 1, undefined)).toEqual(0);
      });
    });

    describe('#saveRetry', function() {
      var score1 = {id: 1, evidence: "hello", value: 1, editMode: null};
      var question1 = {id: 1, score: score1};
      var answer1 = {id: 1, value: 2};

      beforeEach(function() {
        spyOn($modal, 'open');
        subject.saveRetry(scope, answer1, question1);
      });

      it('calls modal open', function() {
        expect($modal.open).toHaveBeenCalled();
      });

      it('sets retryScorePost function to scope', function() {
        spyOn(scope, 'retryScorePost');
        expect(scope.retryScorePost).not.toHaveBeenCalled();
      });

      it('sets cancel function to scope', function() {
        spyOn(scope, 'cancel');
        expect(scope.cancel).not.toHaveBeenCalled();
      });

    });

    describe('#assignAnswerToQuestion', function() {
      var scoreResource;
      var score1 = {id: 1, evidence: "hello", value: 1, editMode: null};
      var question1 = {id: 1, score: score1};
      var answer1 = {id: 1, value: 2};

      beforeEach(inject(function($injector, Score) {
        scope.isReadOnly = false;
        scoreResource = Score;
        scope.responseId = 1;
        scope.assessmentId = 1;
      }));

      it('will set question.loading to true if $scope.isReadOnly is false', function() {
        subject.assignAnswerToQuestion(scope, answer1, question1);
        expect(question1.loading).toEqual(true);
      });

      it('will set question.loading to true', function() {
        subject.assignAnswerToQuestion(scope, answer1, question1);
        expect(question1.loading).toEqual(true);
      });

      it('sends a post request to the scores endpoint', function() {
        $httpBackend.expectPOST('/v1/assessments/1/responses/1/scores').respond({});
        subject.assignAnswerToQuestion(scope, answer1, question1);
        $httpBackend.flush();
      });

      it('sends the correct Params to Score', function() {
        spyOn(scoreResource, 'save')
            .and.callFake(function(params, score) {
          expect(score.question_id).toEqual(1);
          expect(score.value).toEqual(2);
          expect(score.evidence).toEqual("hello");
          var deferred = $q.defer();
          deferred.reject(false);
          return {$promise: deferred.promise};
        });

        subject.assignAnswerToQuestion(scope, answer1, question1);
      });

      it('isAlert should be false if score evidence is missing', function() {
        spyOn(scoreResource, 'save')
            .and.callFake(function() {
          var deferred = $q.defer();
          deferred.resolve({});
          return {$promise: deferred.promise};
        });

        subject.assignAnswerToQuestion(scope, answer1, question1);
        expect(question1.isAlert).toEqual(false);

      });

      describe('resolved promise', function() {
        beforeEach(function() {
          spyOn(subject, 'saveRetry');
          $httpBackend.expectPOST('/v1/assessments/1/responses/1/scores').respond({});
        });

        it('does not call saveRetry', function() {
          subject.assignAnswerToQuestion(scope, answer1, question1);
          $httpBackend.flush();
          expect(subject.saveRetry).not.toHaveBeenCalled();
        });

        it('sets loading to false', function() {
          subject.assignAnswerToQuestion(scope, answer1, question1);
          $httpBackend.flush();
          expect(question1.loading).toEqual(false);
        });

        it('sets question score value to the given answer', function() {
          subject.assignAnswerToQuestion(scope, answer1, question1);
          $httpBackend.flush();
          expect(question1.score.value).toEqual(2);
        });
      });

      describe('401 POST  error', function() {
        beforeEach(function() {
          spyOn(subject, 'saveRetry');
          $httpBackend.expectPOST('/v1/assessments/1/responses/1/scores').respond(401, {});
        });

        it('calls saveRetry', function() {
          subject.assignAnswerToQuestion(scope, answer1, question1);
          $httpBackend.flush();
          expect(subject.saveRetry).toHaveBeenCalled();
        });
      });

      describe('#questionColor', function() {
        it('returns null if question has no score', function() {
          var question = {};
          expect(subject.questionColor(question)).toEqual(null);
        });

        it('returns scored-null when score is present and isConesensus is true', function() {
          var question = {score: {value: null, evidence: null}};
          expect(subject.questionColor(question, true)).toEqual("scored-null");
        });

        it('returns scored-skipped when score is present and isConesensus is false', function() {
          var question = {score: {value: null, evidence: ''}};
          expect(subject.questionColor(question, false)).toEqual("scored-skipped");
        });

        it('returns score value when present', function() {
          var question = {score: {value: 2, evidence: ''}};
          expect(subject.questionColor(question, false)).toEqual("scored-2");
        });

        it('returns score value when present and isConesensus is true', function() {
          var question = {score: {value: 2, evidence: ''}};
          expect(subject.questionColor(question, true)).toEqual("scored-2");
        });

      });

      describe('#skipped', function() {
        it('returns false when a question doesnt have an answer', function() {
          var question = {};
          expect(subject.skipped(question)).toEqual(false);
        });

        it('returns false when evidence null when ', function() {
          var question = {score: {value: null, evidence: null}};
          expect(subject.skipped(question)).toEqual(false);
        });

        it('returns true when evidence is present and value is null ', function() {
          var question = {score: {value: null, evidence: ''}};
          expect(subject.skipped(question)).toEqual(true);
        });

        it('returns false when evidence is present and value is not null ', function() {
          var question = {score: {value: 1, evidence: ''}};
          expect(subject.skipped(question)).toEqual(false);
        });

      });
    });
  });
})();

