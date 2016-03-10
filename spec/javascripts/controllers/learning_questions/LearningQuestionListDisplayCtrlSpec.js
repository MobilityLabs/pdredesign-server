(function() {
  'use strict';

  describe('Controller: LearningQuestionListDisplay', function() {
    describe('when the state parameter matches :id', function() {
      var controller,
          LearningQuestion,
          $scope,
          $window,
          $httpBackend;

      beforeEach(function() {
        module('PDRClient');
        inject(function($injector, $controller, $rootScope) {
          LearningQuestion = $injector.get('LearningQuestion');
          $scope = $rootScope.$new(true);
          $httpBackend = $injector.get('$httpBackend');
          $window = $injector.get('$window');

          controller = $controller('LearningQuestionListDisplayCtrl', {
            $scope: $scope,
            $stateParams: {id: 1},
            LearningQuestion: LearningQuestion,
            $window: $window
          });
        });
      });

      afterEach(function() {
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.resetExpectations();
      });

      it('loads questions in at controller instantiation', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });

        $httpBackend.flush();
        expect(controller.learningQuestions.length).toEqual(1);
      });

      it('does not emit a change event if the entity is not editable', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });
        var invoked = false;
        spyOn($window, 'confirm').and.returnValue(false);
        $httpBackend.when('DELETE', '/v1/assessments/1/learning_questions/1').respond(function() {
          invoked = true;
          return {400: []};
        });
        controller.deleteLearningQuestion({id: 1, editable: false});

        $httpBackend.flush();
        expect(invoked).toBe(false);
      });

      it('does not emit a change event if the user does not delete the entity', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });
        var invoked = false;
        spyOn($window, 'confirm').and.returnValue(false);
        $httpBackend.when('DELETE', '/v1/assessments/1/learning_questions/1').respond(function() {
          invoked = true;
          return {400: []};
        });
        controller.deleteLearningQuestion({id: 1, editable: true});

        $httpBackend.flush();
        expect(invoked).toBe(false);
      });

      it('emits a change event if the user deletes the entity', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });
        spyOn($window, 'confirm').and.returnValue(true);
        spyOn($scope, '$emit');
        $httpBackend.expect('DELETE', '/v1/assessments/1/learning_questions/1').respond({204: {}});
        controller.deleteLearningQuestion({id: 1, editable: true});

        $httpBackend.flush();
        expect($scope.$emit).toHaveBeenCalledWith('learning-question-change');
      });

      it('does not emit a change event if the model is not updatable', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });

        spyOn($scope, '$emit');
        controller.updateLearningQuestion({id: 1, editable: false, body: 'Hello world!'});

        expect($scope.$emit).not.toHaveBeenCalled();
      });

      it('emits a change event if the model is successfully updated', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });

        spyOn($scope, '$emit');
        $httpBackend.expect('PATCH', '/v1/assessments/1/learning_questions/1').respond({200: {}});

        controller.updateLearningQuestion({id: 1, editable: true, body: 'Hello world!'});
        $httpBackend.flush();

        expect($scope.$emit).toHaveBeenCalledWith('learning-question-change');
      });

      it('emits a change event if the model is not successfully updated', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });

        spyOn($scope, '$emit');
        $httpBackend.expect('PATCH', '/v1/assessments/1/learning_questions/1').respond({400: {}});

        controller.updateLearningQuestion({id: 1, editable: true, body: 'Hello world!'});
        $httpBackend.flush();

        expect($scope.$emit).toHaveBeenCalledWith('learning-question-change');
      });
    });


    describe('when the state parameter matches :assessment_id', function() {
      var controller,
          LearningQuestion,
          $scope,
          $window,
          $httpBackend;

      beforeEach(function() {
        module('PDRClient');
        inject(function($injector, $controller, $rootScope) {
          LearningQuestion = $injector.get('LearningQuestion');
          $scope = $rootScope.$new(true);
          $httpBackend = $injector.get('$httpBackend');
          $window = $injector.get('$window');

          controller = $controller('LearningQuestionListDisplayCtrl', {
            $scope: $scope,
            $stateParams: {id: 12},
            LearningQuestion: LearningQuestion,
            $window: $window
          });
        });
      });

      afterEach(function() {
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.resetExpectations();
      });

      it('refers to :assessment_id if it is available', function() {

        $httpBackend.expect('GET', '/v1/assessments/12/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 12,
              editable: true,
              body: 'Hello world!'
            }
          ]
        });

        $httpBackend.flush();
        expect(controller.learningQuestions.length).toEqual(1);
      });
    });
  });
})();