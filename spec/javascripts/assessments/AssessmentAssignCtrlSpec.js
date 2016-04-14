(function() {
  'use strict';

  describe('Controller:  AssessmentAssign', function() {
    var subject,
        $controller,
        $scope,
        $timeout,
        $anchorScroll,
        $stateParams,
        $httpBackend,
        SessionService,
        Assessment,
        CreateService;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$rootScope_, _$timeout_, _$location_, _$anchorScroll_, _$httpBackend_, $injector) {
        $scope = _$rootScope_.$new(true);
        $timeout = _$timeout_;
        $anchorScroll = _$anchorScroll_;
        $httpBackend = _$httpBackend_;
        $controller = _$controller_;

        SessionService = $injector.get('SessionService');
        CreateService = $injector.get('CreateService');
        Assessment = $injector.get('Assessment');
      });
    });

    describe('#fetchAssessment', function() {
      describe('when an assessment with ID of 1 is found', function() {
        describe('when the user has a matching district', function() {
          beforeEach(function() {
            $stateParams = {id: 1};
            spyOn(SessionService, 'getCurrentUser').and.returnValue(
                {
                  districts: [
                    {
                      id: 19
                    },
                    {
                      id: 12
                    }
                  ]
                });
            $httpBackend.expect('GET', '/v1/assessments/1').respond({id: 7, district_id: 12});

            subject = $controller('AssessmentAssignCtrl', {
              $scope: $scope,
              $timeout: $timeout,
              $anchorScroll: $anchorScroll,
              $stateParams: $stateParams,
              SessionService: SessionService,
              Assessment: Assessment,
              CreateService: CreateService
            });

            $httpBackend.flush();
          });

          it('binds the assessment to the scope (by virtue of its ID)', function() {
            expect($scope.assessment.id).toEqual(7);
          });

          it('sets the scope district correctly', function() {
            expect($scope.district).toEqual({id: 12});
          });

          afterEach(function() {
            $httpBackend.verifyNoOutstandingExpectation();
            $httpBackend.verifyNoOutstandingRequest();
          });
        });

        describe('when the user does not have a matching district', function() {
          beforeEach(function() {
            $stateParams = {id: 1};
            spyOn(SessionService, 'getCurrentUser').and.returnValue(
                {
                  districts: [
                    {
                      id: 30
                    },
                    {
                      id: 13
                    }
                  ]
                });
            $httpBackend.expect('GET', '/v1/assessments/1').respond({id: 7, district_id: 12});

            subject = $controller('AssessmentAssignCtrl', {
              $scope: $scope,
              $timeout: $timeout,
              $anchorScroll: $anchorScroll,
              $stateParams: $stateParams,
              SessionService: SessionService,
              Assessment: Assessment,
              CreateService: CreateService
            });

            $httpBackend.flush();
          });

          it('binds the assessment to the scope (by virtue of its ID)', function() {
            expect($scope.assessment.id).toEqual(7);
          });

          it('sets the district to the first entry in the list', function() {
            expect($scope.district).toEqual({id: 30});
          });

          afterEach(function() {
            $httpBackend.verifyNoOutstandingExpectation();
            $httpBackend.verifyNoOutstandingRequest();
          });
        });
      });

      describe('when an assessment with ID 1 is not found', function() {
        beforeEach(function() {
          $stateParams = {id: 1};
          spyOn(SessionService, 'getCurrentUser').and.returnValue(
              {
                districts: [
                  {
                    id: 19
                  },
                  {
                    id: 12
                  }
                ]
              });
          $httpBackend.when('GET', '/v1/assessments/1').respond(400);

          subject = $controller('AssessmentAssignCtrl', {
            $scope: $scope,
            $timeout: $timeout,
            $anchorScroll: $anchorScroll,
            $stateParams: $stateParams,
            SessionService: SessionService,
            Assessment: Assessment,
            CreateService: CreateService
          });

          $httpBackend.flush();
        });

        it('does not set the assessment', function() {
          expect($scope.assessment).toBeUndefined();
        });

        afterEach(function() {
          $httpBackend.verifyNoOutstandingExpectation();
          $httpBackend.verifyNoOutstandingRequest();
        });
      });
    });

    describe('#assignAndSave', function() {
      var assessment = {id: 1};
      beforeEach(function() {
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue(
            {
              districts: [
                {
                  id: 19
                }
              ]
            });
        $httpBackend.expect('GET', '/v1/assessments/1').respond({});

        subject = $controller('AssessmentAssignCtrl', {
          $scope: $scope,
          $timeout: $timeout,
          $anchorScroll: $anchorScroll,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Assessment: Assessment,
          CreateService: CreateService
        });

        $httpBackend.flush();
        spyOn(CreateService, 'assignAndSaveAssessment');
      });

      it('delegates to CreateService', function() {
        $scope.assignAndSave(assessment);
        expect(CreateService.assignAndSaveAssessment).toHaveBeenCalled();
      });

      afterEach(function() {
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
      });
    });

    describe('#save', function() {
      var assessment = {id: 1};
      beforeEach(function() {
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue(
            {
              districts: [
                {
                  id: 19
                },
                {
                  id: 12
                }
              ]
            });
        $httpBackend.when('GET', '/v1/assessments/1').respond({});

        subject = $controller('AssessmentAssignCtrl', {
          $scope: $scope,
          $timeout: $timeout,
          $anchorScroll: $anchorScroll,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Assessment: Assessment,
          CreateService: CreateService
        });

        $httpBackend.flush();
        spyOn(CreateService, 'saveAssessment');
      });

      it('delegates to CreateService', function() {
        $scope.save(assessment);
        expect(CreateService.saveAssessment).toHaveBeenCalled();
      });
    });

    describe('#success', function() {
      var anchorScroll = jasmine.createSpy('anchorScroll');
      beforeEach(function() {
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});

        subject = $controller('AssessmentAssignCtrl', {
          $scope: $scope,
          $timeout: $timeout,
          $anchorScroll: anchorScroll,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Assessment: Assessment,
          CreateService: CreateService
        });
      });

      it('adds the message to the alerts array', function() {
        $scope.success('Success!');
        expect($scope.alerts[0]).toEqual({type: 'success', msg: 'Success!'});
      });

      it('invokes the $anchorScroll service', function() {
        $scope.success('Success!');
        expect(anchorScroll).toHaveBeenCalled();
      });

      it('removes the alert after the timeout', function() {
        $httpBackend.when('GET', '/v1/assessments/1').respond({});

        $scope.success('Success!');
        expect($scope.alerts.length).toEqual(1);
        $timeout.flush();
        expect($scope.alerts.length).toEqual(0);
      });
    });


    describe('#error', function() {
      var anchorScroll = jasmine.createSpy('anchorScroll');
      beforeEach(function() {
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});

        subject = $controller('AssessmentAssignCtrl', {
          $scope: $scope,
          $timeout: $timeout,
          $anchorScroll: anchorScroll,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Assessment: Assessment,
          CreateService: CreateService
        });
      });

      it('adds the message to the alerts array', function() {
        $scope.error('Error!');
        expect($scope.alerts[0]).toEqual({type: 'danger', msg: 'Error!'});
      });

      it('invokes the $anchorScroll service', function() {
        $scope.error('Error!');
        expect(anchorScroll).toHaveBeenCalled();
      });
    });

    describe('$on: add_assessment_alert', function() {
      var $rootScope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });
        $stateParams = {id: 1};
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 19}]});

        subject = $controller('AssessmentAssignCtrl', {
          $scope: $scope,
          $timeout: $timeout,
          $anchorScroll: $anchorScroll,
          $stateParams: $stateParams,
          SessionService: SessionService,
          Assessment: Assessment,
          CreateService: CreateService
        });
      });

      describe('when the data type is success', function() {
        it('invokes success with the right parameters', function() {
          spyOn($scope, 'success');
          $rootScope.$broadcast('add_assessment_alert', {type: 'success', msg: 'This is a success!'});
          expect($scope.success).toHaveBeenCalledWith('This is a success!');
        });
      });

      describe('when the data type is danger', function() {
        it('invokes error with the right parameters', function() {
          spyOn($scope, 'error');
          $rootScope.$broadcast('add_assessment_alert', {type: 'danger', msg: 'This is a warning!'});
          expect($scope.error).toHaveBeenCalledWith('This is a warning!');
        });
      });

      describe('when the data type is anything else', function() {
        it('invokes no methods', function() {
          spyOn($scope, 'success');
          spyOn($scope, 'error');
          $rootScope.$broadcast('add_assessment_alert', {type: 'error', msg: 'This really will not be invoked'});
          expect($scope.success).not.toHaveBeenCalled();
          expect($scope.error).not.toHaveBeenCalled();
        });
      });
    });
  });
})();
