(function() {
  'use strict';
  describe('Resource: LearningQuestion', function() {

    var subject, $httpBackend, $resource;

    beforeEach(module('PDRClient'));
    beforeEach(inject(function($injector) {
      subject = $injector.get('LearningQuestion');
      $resource = $injector.get('$resource');
      $httpBackend = $injector.get('$httpBackend');
    }));

    describe('#GET (all)', function() {
      it('uses the right URL', function() {
        $httpBackend.expectGET('/v1/assessments/1/learning_questions').respond({learning_questions: []});
        subject.get({assessment_id: 1});
        $httpBackend.flush();
      });
    });

    describe('#GET (individual)', function() {
      it('uses the right URL', function() {
        $httpBackend.expectGET('/v1/assessments/1/learning_questions/3').respond({learning_question: {}});
        subject.get({assessment_id: 1, id: 3});
        $httpBackend.flush();
      });
    });

    describe('#GET (exists)', function() {
      it('uses the right URL', function() {
        $httpBackend.expectGET('/v1/assessments/1/learning_questions/exists').respond({200: {}});
        subject.exists({assessment_id: 1});
        $httpBackend.flush();
      });
    });

    describe('#POST', function() {
      it('uses the right URL', function() {
        $httpBackend.expectPOST('/v1/assessments/1/learning_questions').respond(201);
        subject.create({assessment_id: 1}, {learning_question: {body: 'Hello!'}});
        $httpBackend.flush();
      })
    });

    describe('#PATCH', function() {
      it('uses the right URL', function() {
        $httpBackend.expectPATCH('/v1/assessments/1/learning_questions/3').respond(204);
        subject.update({assessment_id: 1, id: 3}, {learning_question: {body: 'Hi!'}});
        $httpBackend.flush();
      })
    });

    describe('#DELETE', function() {
      it('uses the right url', function() {
        $httpBackend.expectDELETE('/v1/assessments/1/learning_questions/3').respond(201);
        subject.delete({assessment_id: 1, id: 3});
        $httpBackend.flush();
      })
    })
  });
})();