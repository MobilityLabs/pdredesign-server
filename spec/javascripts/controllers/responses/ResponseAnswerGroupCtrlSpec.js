(function() {
  'use strict';
  describe('Controller: ResponseAnswerGroupCtrl', function() {

    var $scope,
        $stateParams,
        ResponseHelper,
        ResponseValidationService,
        controller;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _ResponseHelper_, _ResponseValidationService_, $controller) {
        $scope = _$rootScope_.$new(true);
        ResponseHelper = _ResponseHelper_;
        ResponseValidationService = _ResponseValidationService_;
        $stateParams = {response_id: 13, assessment_id: 19};
        controller = $controller('ResponseAnswerGroupCtrl', {
          $scope: $scope,
          $stateParams: $stateParams
        });
      });
    });

    it('binds the response ID to the scope', function() {
      expect($scope.responseId).toEqual(13);
    });

    it('binds the response ID to the controller', function() {
      expect(controller.responseId).toEqual(13);
    });

    it('binds the assessment ID to the scope', function() {
      expect($scope.assessmentId).toEqual(19);
    });

    it('binds the assessment ID to the controller', function() {
      expect(controller.assessmentId).toEqual(19);
    });

    describe('when assigning an answer to a question', function() {
      describe('when the consensus === \'true\' on the scope', function() {
        beforeEach(function() {
          inject(function(_$rootScope_, $controller) {
            $scope = _$rootScope_.$new(true);
            $scope.isConsensus = 'true';
            controller = $controller('ResponseAnswerGroupCtrl', {
              $scope: $scope,
              $stateParams: $stateParams
            });
          });
        });

        describe('when no score is passed', function() {
          var question, result;

          beforeEach(function() {
            question = {};
            spyOn(ResponseHelper, 'assignAnswerToQuestion');
            result = controller.assignAnswerToQuestion({}, question);
          });

          it('sets the isAlert property to true on the question', function() {
            expect(question.isAlert).toBe(true);
          });

          it('delegates to the ResponseHelper', function() {
            expect(ResponseHelper.assignAnswerToQuestion).not.toHaveBeenCalledWith($scope, {}, question);
          });
        });

        describe('when evidence is null', function() {
          var question, result;

          beforeEach(function() {
            question = {score: {evidence: null}};
            spyOn(ResponseHelper, 'assignAnswerToQuestion');
            result = controller.assignAnswerToQuestion({}, question);
          });

          it('sets the isAlert property to true on the question', function() {
            expect(question.isAlert).toBe(true);
          });

          it('delegates to the ResponseHelper', function() {
            expect(ResponseHelper.assignAnswerToQuestion).not.toHaveBeenCalledWith($scope, {}, question);
          });
        });

        describe('when evidence is blank', function() {
          var question, result;

          beforeEach(function() {
            question = {score: {evidence: ''}};
            spyOn(ResponseHelper, 'assignAnswerToQuestion');
            result = controller.assignAnswerToQuestion({}, question);
          });

          it('sets the isAlert property to true on the question', function() {
            expect(question.isAlert).toBe(true);
          });

          it('delegates to the ResponseHelper', function() {
            expect(ResponseHelper.assignAnswerToQuestion).not.toHaveBeenCalledWith($scope, {}, question);
          });
        });

        describe('when evidence is present', function() {
          var question, result;

          beforeEach(function() {
            question = {score: {evidence: 'not null'}};
            spyOn(ResponseHelper, 'assignAnswerToQuestion');
            result = controller.assignAnswerToQuestion({}, question);
          });

          it('does not set the isAlert property', function() {
            expect(question.isAlert).not.toBe(true);
          });

          it('delegates to the ResponseHelper', function() {
            expect(ResponseHelper.assignAnswerToQuestion).toHaveBeenCalledWith($scope, {}, question);
          });
        });
      });
    });
  });
})();
