(function() {
  'use strict';

  describe('Controller: CreateParticipants', function() {
    var subject,
        $scope,
        $stateParams,
        $controller,
        $httpBackend,
        SessionService,
        Participant;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$rootScope_, _$httpBackend_, $injector) {
        $scope = _$rootScope_.$new(true);
        $controller = _$controller_;
        $httpBackend = _$httpBackend_;
        SessionService = $injector.get('SessionService');
        Participant = $injector.get('Participant');
      });
    });

    it('always fetches current list of participants', function() {
      beforeEach(function() {
        $stateParams = {id: 1};
        subject = $controller('CreateParticipantsCtrl', {
          $scope: $scope,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Participant: Participant
        });
      });

      it('makes the request successfully', function() {
        $httpBackend.expect('GET', '/v1/assessments/1/participants').respond(200, []);
        $httpBackend.flush();

        $httpBackend.verifyNoOutstandingRequest();
        $httpBackend.verifyNoOutstandingExpectation();
      });

    });

    describe('$on: update_participants', function() {
      var $rootScope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});

        subject = $controller('CreateParticipantsCtrl', {
          $scope: $scope,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Participant: Participant
        });
      });

      it('invokes the correct method', function() {
        spyOn(subject, 'updateParticipantsList');
        $rootScope.$broadcast('update_participants');
        expect(subject.updateParticipantsList).toHaveBeenCalled();
      });
    });

    describe('#isNetworkPartner', function() {
      beforeEach(function() {
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});
        spyOn(SessionService, 'isNetworkPartner');

        subject = $controller('CreateParticipantsCtrl', {
          $scope: $scope,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Participant: Participant
        });
      });

      it('delegates to SessionService', function() {
        subject.isNetworkPartner();
        expect(SessionService.isNetworkPartner).toHaveBeenCalled();
      });
    });

    describe('#removeParticipant', function() {
      describe('when successful', function() {
        var user = {id: 5, participant_id: 17};
        beforeEach(function() {
          $stateParams = {id: 1};
          spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});

          subject = $controller('CreateParticipantsCtrl', {
            $scope: $scope,
            $stateParams: $stateParams,
            SessionService: SessionService,
            Participant: Participant
          });
          spyOn(subject, 'updateParticipantsList');
          $httpBackend.expect('GET', '/v1/assessments/1/participants').respond(200, []);
          $httpBackend.when('DELETE', '/v1/assessments/1/participants/17', {
            assessment_id: 1,
            id: 17
          }).respond(204, {});
        });

        it('calls #updateParticipantsList', function() {
          subject.removeParticipant(user);
          $httpBackend.flush();
          expect(subject.updateParticipantsList).toHaveBeenCalled();
        });

        afterEach(function() {
          $httpBackend.verifyNoOutstandingRequest();
          $httpBackend.verifyNoOutstandingExpectation();
        });
      });

      describe('when unsuccessful', function() {
        var user = {id: 5, participant_id: 17};
        beforeEach(function() {
          $stateParams = {id: 1};
          spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});

          subject = $controller('CreateParticipantsCtrl', {
            $scope: $scope,
            $stateParams: $stateParams,
            SessionService: SessionService,
            Participant: Participant
          });
          spyOn(subject, 'updateParticipantsList');
          $httpBackend.expect('GET', '/v1/assessments/1/participants').respond(200, []);
          $httpBackend.when('DELETE', '/v1/assessments/1/participants/17', {
            assessment_id: 1,
            id: 17
          }).respond(400, {});
        });

        it('does not call #updateParticipantsList', function() {
          subject.removeParticipant(user);
          $httpBackend.flush();
          expect(subject.updateParticipantsList).not.toHaveBeenCalled();
        });

        afterEach(function() {
          $httpBackend.verifyNoOutstandingRequest();
          $httpBackend.verifyNoOutstandingExpectation();
        });
      });
    });

    describe('#updateParticipantsList', function() {
      var CreateService;
      beforeEach(function() {
        inject(function($injector) {
          CreateService = $injector.get('CreateService');
        });
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});

        subject = $controller('CreateParticipantsCtrl', {
          $scope: $scope,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Participant: Participant
        });
      });

      describe('when Participant#query and Participant#all are successful', function() {
        beforeEach(function() {
          $httpBackend.when('GET', '/v1/assessments/1/participants').respond(200, [{id: 1}]);
          $httpBackend.when('GET', '/v1/assessments/1/participants/all').respond(200, [{id: 178}]);
        });

        it('places the value into participants', function() {
          subject.updateParticipantsList();
          $httpBackend.flush();
          expect(subject.participants[0].id).toEqual(1)
        });

        it('places the value into invitableParticipants', function() {
          subject.updateParticipantsList();
          $httpBackend.flush();
          expect(subject.invitableParticipants[0].id).toEqual(178)
        });
      });

      describe('when Participant#query is unsuccessful', function() {
        beforeEach(function() {
          spyOn(CreateService, 'emitError');
          subject = $controller('CreateParticipantsCtrl', {
            $scope: $scope,
            $stateParams: $stateParams,
            SessionService: SessionService,
            Participant: Participant,
            CreateService: CreateService
          });
          $httpBackend.when('GET', '/v1/assessments/1/participants').respond(400);
          $httpBackend.when('GET', '/v1/assessments/1/participants/all').respond(200);
        });

        it('emits the error', function() {
          subject.updateParticipantsList();
          $httpBackend.flush();
          expect(CreateService.emitError).toHaveBeenCalledWith('Could not update participants list');
        });
      });

      describe('when Participant#all is unsuccessful', function() {
        beforeEach(function() {
          spyOn(CreateService, 'emitError');
          subject = $controller('CreateParticipantsCtrl', {
            $scope: $scope,
            $stateParams: $stateParams,
            SessionService: SessionService,
            Participant: Participant,
            CreateService: CreateService
          });
          $httpBackend.when('GET', '/v1/assessments/1/participants').respond(200);
          $httpBackend.when('GET', '/v1/assessments/1/participants/all').respond(400);
        });

        it('emits the error', function() {
          subject.updateParticipantsList();
          $httpBackend.flush();
          expect(CreateService.emitError).toHaveBeenCalledWith('Could not update participants list');
        });
      });

      describe('when Participant#query and Participant#all are unsuccessful', function() {
        beforeEach(function() {
          spyOn(CreateService, 'emitError');
          subject = $controller('CreateParticipantsCtrl', {
            $scope: $scope,
            $stateParams: $stateParams,
            SessionService: SessionService,
            Participant: Participant,
            CreateService: CreateService
          });
          $httpBackend.when('GET', '/v1/assessments/1/participants').respond(400);
          $httpBackend.when('GET', '/v1/assessments/1/participants/all').respond(400);
        });

        it('emits the error twice', function() {
          subject.updateParticipantsList();
          $httpBackend.flush();
          expect(CreateService.emitError.calls.count()).toEqual(2);
        });
      });
    });
  });
})();