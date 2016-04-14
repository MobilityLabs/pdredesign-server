(function() {
  'use strict';

  describe('Controller: StartAssessmentCtrl', function() {
    var $scope, $timeout, $q, $httpBackend, controller, Assessment, SessionService;

    var user = {role: "facilitator", districts: [{id: 1}]};
    var assessment = {id: 1, due_date: null, rubric_id: null};

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$timeout_, _$rootScope_, _$q_, _$controller_, _$httpBackend_, $injector) {
        $scope = _$rootScope_.$new(true);
        $timeout = _$timeout_;
        $httpBackend = _$httpBackend_;
        $q = _$q_;
        Assessment = $injector.get('Assessment');
        SessionService = $injector.get('SessionService');
        spyOn(SessionService, 'getCurrentUser').and.returnValue(user);
        spyOn(SessionService, 'syncUser').and.returnValue(true);
        controller = _$controller_('StartAssessmentCtrl', {
          $scope: $scope,
          $timeout: $timeout,
          $q: $q,
          Assessment: Assessment,
          SessionService: SessionService
        });
      });
    });

    describe('#text', function() {
      it('returns Facilitate New Assessment when a user is a district user', function() {
        spyOn(SessionService, 'isNetworkPartner').and.returnValue(false);
        expect(controller.text()).toEqual('Facilitate New Assessment');
      });

      it('returns Recommend Assessment when a user is a network Partner', function() {
        spyOn(SessionService, 'isNetworkPartner').and.returnValue(true);
        expect(controller.text()).toEqual('Recommend Assessment');
      });
    });

    describe('#create', function() {

      it('sets the district_id to selected district', function() {
        $httpBackend.expect('POST', '/v1/assessments', assessment).respond(assessment);
        controller.district = {id: 55};

        controller.create(assessment);
        $httpBackend.flush();

        expect(assessment.district_id).toEqual(55);
      });

      it('sets assessment due date ', function() {
        $httpBackend.expect('POST', '/v1/assessments', assessment).respond(assessment);
        var today = new Date();
        assessment.due_date = null;
        $("#due-date").val(today);

        controller.create(assessment);
        $httpBackend.flush();

        expect(moment(assessment.due_date).format('dddd')).toEqual(moment(today).format('dddd'));
      });

      it('redirects to the assessment assign page when success', function() {
        $httpBackend.expect('POST', '/v1/assessments', assessment).respond(assessment);
        spyOn(controller, 'redirectToAssessment');

        controller.create(assessment);
        $httpBackend.flush();

        expect(controller.redirectToAssessment).toHaveBeenCalled();
      });

      afterEach(function() {
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
      })
    });
  });
})();
