(function() {
  'use strict';
  describe('Controller: AssessmentsCtrl', function() {
    var subject, $scope, $httpBackend, SessionService;

    beforeEach(function() {
      module('PDRClient');
      inject(function($controller, $rootScope, $injector) {

        $httpBackend = $injector.get('$httpBackend');
        SessionService = $injector.get('SessionService');

        spyOn(SessionService, 'getCurrentUser')
            .and.returnValue({role: 'member'});

        $scope = $rootScope.$new();
        subject = $controller('AssessmentsCtrl', {
          $scope: $scope,
          assessments: {}
        });
      });
    });

    describe('#districtOptions', function() {
      it('returns all unique districts', function() {
        var assessments = [
          {district_name: 'first'},
          {district_name: 'first'},
          {district_name: 'second'},
          {district_name: 'second'}
        ];

        var districts = $scope.districtOptions(assessments);
        expect(districts).toEqual(['first', 'second'])
      });
    });

    describe('#statusesOptions', function() {
      it('returns all unique statuses', function() {
        var assessments = [
          {status: 'draft'},
          {status: 'consensus'},
          {status: 'draft'},
          {status: 'consensus'}
        ];

        var statuses = $scope.statusesOptions(assessments);
        expect(statuses).toEqual(['draft', 'consensus'])
      });
    });

    describe('#permissionsFilter', function() {
      it('Organizer should return is_facilitator true', function() {
        var permission = $scope.permissionsFilter('Organizer');
        expect(permission).toEqual({is_facilitator: true})
      });

      it('Participant should return is_participant true', function() {
        var permission = $scope.permissionsFilter('Observer');
        expect(permission).toEqual({is_participant: true})
      });
    });
  });
})();
