(function() {
  'use strict';
  describe('Controller: AssessmentDashboardSidebarCtrl', function() {
    var $scope, $q, $location, $httpBackend, subject;

    var today = new Date();
    var nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);

    beforeEach(function() {
      module('PDRClient');
      inject(function($injector, $controller, $rootScope) {
        $scope = $rootScope.$new(true);
        $q = $injector.get('$q');
        $httpBackend = $injector.get('$httpBackend');
        $location = $injector.get('$location');

        subject = $controller('AssessmentDashboardSidebarCtrl', {
          $scope: $scope
        });

        $httpBackend.when('GET', '/v1/assessments').respond({});
      })
    });

    it('sends a reminder to the server', function() {
      $scope.close = function() { };
      $httpBackend.expectPOST('/v1/assessments/99/reminders').respond({});

      $scope.id = 99;
      $scope.sendReminder("Something");
      $httpBackend.flush();
    });

    it('closes the modal after a reminder has been sent', function() {
      spyOn($scope, 'close');
      $httpBackend.when('POST', '/v1/assessments/99/reminders').respond({});

      $scope.id = 99;
      $scope.sendReminder("Something");
      $httpBackend.flush();

      expect($scope.close).toHaveBeenCalled();
    });

    it('postMeetingDate should be false for meeting date that is nextWeek', function() {
      $scope.assessment.meeting_date = nextWeek;
      expect($scope.postMeetingDate()).toEqual(false);
    });

    it('preMeetingDate should be true for meeting date that is nextWeek', function() {
      $scope.assessment.meeting_date = nextWeek;
      expect($scope.preMeetingDate()).toEqual(true);
    });

    it('noMeetingDate should be true for meeting date that is null', function() {
      $scope.assessment.meeting_date = null;
      expect($scope.noMeetingDate()).toEqual(true);
    });

    it("reportPresent should be true if consensus has been submitted ", function() {
      $scope.assessment.submitted_at = "something";
      expect($scope.reportPresent()).toEqual(true);
    });

    it("reportPresent should be false if consensus submitted_at is null", function() {
      $scope.assessment.submitted_at = null;
      expect($scope.reportPresent()).toEqual(false);
    });

    describe('#redirectToCreateConsensus', function() {
      beforeEach(function() {
        spyOn($scope, 'close');
      });

      it('sends user to correct URL by passing scope.id', function() {
        $scope.id = 1;
        $scope.redirectToCreateConsensus();
        expect($location.path()).toEqual('/assessments/1/consensus')
      });

      it('closes the currently open modal', function() {
        $scope.redirectToCreateConsensus();
        expect($scope.close).toHaveBeenCalled();
      });
    });

    describe('#consensusStarted', function() {
      it('returns false if status is assessment', function() {
        $scope.assessment.status = 'assessment';
        expect($scope.consensusStarted()).toEqual(false);
      });

      it('returns true if status is consensus', function() {
        $scope.assessment.status = 'consensus';
        expect($scope.consensusStarted()).toEqual(true);
      });
    });
  });
})();
