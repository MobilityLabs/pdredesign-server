(function() {
  'use strict';
  describe('Directive: learningQuestionListDisplay', function() {
    describe('when rendering the directive', function() {
      var element,
          $scope,
          $stateParams,
          $httpBackend;

      beforeEach(function() {
        module('PDRClient', function($provide) {
          $provide.provider('$stateParams', function() {
            return {
              $get: function() {
                return {
                  id: 1
                }
              }
            };
          });
        });
        inject(function($rootScope, $injector, $compile, _$httpBackend_) {
          $scope = $rootScope.$new(true);
          $stateParams = {id: 1};
          $httpBackend = _$httpBackend_;
          element = angular.element('<div><learning-question-list-display></learning-question-list-display></div>');
          $compile(element)($scope);
        });
      });

      afterEach(function() {
        $httpBackend.verifyNoOutstandingExpectation();
      });

      it('displays no elements when none exist', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {learning_questions: []});

        $scope.$digest();
        $httpBackend.flush();
        expect(element.children().length).toEqual(0);
      });

      it('displays three elements when three exist', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 1,
              editable: true,
              body: 'foo'
            },
            {
              id: 2,
              editable: true,
              body: 'foo'
            },
            {
              id: 3,
              editable: true,
              body: 'foo'
            }]
        });

        $scope.$digest();
        $httpBackend.flush();

        expect(element.children().length).toEqual(3);
      });

      it('has its child elements contain the correct id', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 77,
              editable: true,
              body: 'foo'
            }]
        });
        $scope.$digest();
        $httpBackend.flush();

        expect(element.find('#learning-question-77')[0]).not.toBeUndefined();
      });

      it('displays the delete button if the question is editable', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 38,
              editable: true,
              body: 'foo'
            }]
        });
        $scope.$digest();
        $httpBackend.flush();

        expect(element.find('.close')[0].classList).not.toContain('ng-hide');
      });

      it('does not display the delete button if the question is not editable', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 38,
              editable: false,
              body: 'foo'
            }]
        });
        $scope.$digest();
        $httpBackend.flush();

        expect(element.find('.close')[0].classList).toContain('ng-hide');
      });

      it('displays the edit button if the question is editable', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 38,
              editable: true,
              body: 'foo'
            }]
        });
        $scope.$digest();
        $httpBackend.flush();

        expect(element.find('.edit')[0].classList).not.toContain('ng-hide');
      });

      it('does not display the edit button if the question is not editable', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 38,
              editable: false,
              body: 'foo'
            }]
        });
        $scope.$digest();
        $httpBackend.flush();

        expect(element.find('.edit')[0].classList).toContain('ng-hide');
      });

      it('displays the body contents', function() {
        $httpBackend.expect('GET',
            '/v1/assessments/1/learning_questions').respond(200, {
          learning_questions: [
            {
              id: 124,
              editable: false,
              body: 'foo'
            }]
        });
        $scope.$digest();
        $httpBackend.flush();

        expect(element.find('.learning-question').text().trim()).toEqual('foo');
      });
    });
  });
})();