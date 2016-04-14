(function() {
  'use strict';

  describe('Service: Create', function() {
    var subject,
        $window,
        $location,
        Assessment;
    beforeEach(function() {
      module('PDRClient');
      inject(function(_$window_, _$location_, _$injector_) {
        $window = _$window_;
        $location = _$location_;
        Assessment = _$injector_.get('Assessment');

        subject = _$injector_.get('CreateService');
      });
    });

    describe('on initialization', function() {
      it('sets alertError to false', function() {
        expect(subject.alertError).toEqual(false);
      });
    });

    describe('#formattedDate', function() {
      it('uses the right format provided to MomentJS', function() {
        var result = subject.formattedDate(new Date('01/01/2001'));
        expect(result).toEqual('Jan 1, 2001');
      });
    });

    describe('#loadDistrict', function() {
      it('sets a value in the service', function() {
        expect(subject.district).toBeUndefined();
        subject.district = {id: 1};
        expect(subject.district).not.toBeUndefined();
      });
    });

    describe('#loadScope', function() {
      it('sets a value in the service', function() {
        expect(subject.scope).toBeUndefined();
        subject.scope = {id: 1};
        expect(subject.scope).not.toBeUndefined();
      });
    });

    describe('#toggleSavingState', function() {
      var $scope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $scope = _$rootScope_.$new(true);
        });
        spyOn($scope, '$emit');
        subject.scope = $scope;
      });

      it('emits the correct event', function() {
        subject.toggleSavingState();
        expect($scope.$emit).toHaveBeenCalledWith('toggle-saving-state');
      });
    });

    describe('#emitSuccess', function() {
      var $scope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $scope = _$rootScope_.$new(true);
        });
        spyOn($scope, '$emit');
        subject.scope = $scope;
      });

      it('emits the correct event', function() {
        subject.emitSuccess('w00t');
        expect($scope.$emit).toHaveBeenCalledWith('add_assessment_alert', {type: 'success', msg: 'w00t'});
      });
    });

    describe('#emitError', function() {
      var $scope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $scope = _$rootScope_.$new(true);
        });
        spyOn($scope, '$emit');
        subject.scope = $scope;
      });

      it('emits the correct event', function() {
        subject.emitError('oh n0ez');
        expect($scope.$emit).toHaveBeenCalledWith('add_assessment_alert', {type: 'danger', msg: 'oh n0ez'});
      });
    });

    describe('#assignAndSaveAssessment', function() {
      var $httpBackend;
      beforeEach(function() {
        inject(function(_$httpBackend_) {
          $httpBackend = _$httpBackend_;
        });
      });

      describe('when the assessment message is null', function() {
        var assessment = {message: null};

        it('sets alertError to true', function() {
          subject.assignAndSaveAssessment(assessment);
          expect(subject.alertError).toBe(true);
        });
      });

      describe('when the assessment message is blank', function() {
        var assessment = {message: ''};

        it('sets alertError to true', function() {
          subject.assignAndSaveAssessment(assessment);
          expect(subject.alertError).toBe(true);
        });
      });

      describe('when the alert dialog is not accepted', function() {
        var assessment = {message: 'This is a test!'};
        var $window;
        beforeEach(function() {
          inject(function(_$window_) {
            $window = _$window_;
          });
          subject.$window = $window;
          spyOn($window, 'confirm').and.returnValue(false);
          spyOn(subject, 'saveAssessment');
        });

        it('does not invoke #saveAssessment', function() {
          subject.assignAndSaveAssessment(assessment);
          expect(subject.saveAssessment).not.toHaveBeenCalled();
        });
      });

      describe('when the alert dialog is accepted', function() {
        var assessment = {message: 'This is a test!'};
        var $window;
        beforeEach(function() {
          inject(function(_$window_) {
            $window = _$window_;
          });
          subject.$window = $window;
          spyOn($window, 'confirm').and.returnValue(true);
          spyOn(subject, 'saveAssessment').and.returnValue({
            then: function(callback) {
              callback();
            }
          });
        });

        it('does call the save method on the scope', function() {
          subject.assignAndSaveAssessment(assessment);
          expect(subject.saveAssessment).toHaveBeenCalled();
        });

        it('sets the location to /assessments', function() {
          subject.assignAndSaveAssessment(assessment);
          expect($location.path()).toEqual('/assessments');
        });
      });
    });

    describe('#saveAssessment', function() {
      describe('when the assessment name is blank', function() {
        beforeEach(function() {
          var assessment = {name: ''};
          spyOn(subject, 'emitError');
          subject.saveAssessment(assessment, true);
        });

        it('invokes #emitError', function() {
          expect(subject.emitError).toHaveBeenCalledWith('Assessment needs a name!');
        });
      });

      describe('when the assessment name is not blank', function() {
        var assessment,
            inputField,
            $scope;

        beforeEach(function() {
          assessment = {id: 1, name: 'This is a test'};
          inject(function(_$rootScope_, _$compile_) {
            $scope = _$rootScope_.$new(true);
            inputField = angular.element('<input class="form-control" id="due-date" data-format="dd/MM/yyyy" name="due-date">');
            angular.element(document.body).append(inputField);
            inputField.val('08/01/1997');
            _$compile_(inputField)($scope);
          });

          subject.district = {id: 1};
          subject.scope = $scope;
        });

        it('pulls the date value from the input form', function() {
          subject.saveAssessment(assessment, true);
          expect(assessment.due_date).toEqual(moment('08/01/1997', 'MM/DD/YYYY').toISOString());
        });

        describe('when assign is true', function() {
          it('sets assessment.assign to true', function() {
            subject.saveAssessment(assessment, true);
            expect(assessment.assign).toEqual(true);
          });
        });

        describe('when assign is false', function() {
          it('leaves assessment.assign undefined', function() {
            subject.saveAssessment(assessment, false);
            expect(assessment.assign).toBeUndefined();
          });
        });

        describe('when the save is successful', function() {
          var successfulAssessment,
              $httpBackend;

          beforeEach(function() {
            successfulAssessment = {
              id: 1,
              name: 'This is a test',
              district_id: 19,
              due_date: moment('08/01/1997', 'MM/DD/YYYY').toISOString(),
              assign: true
            };

            inject(function(_$httpBackend_) {
              $httpBackend = _$httpBackend_;
            });

            subject.district = {id: 1};

            $httpBackend.expect('PUT', '/v1/assessments/1', successfulAssessment).respond(201);
          });

          it('invokes #emitSuccess function with the correct parameter', function() {
            spyOn(subject, 'emitSuccess');
            subject.saveAssessment(successfulAssessment, true);
            $httpBackend.flush();
            expect(subject.emitSuccess).toHaveBeenCalledWith('Assessment Saved!');
          });

          afterEach(function() {
            $httpBackend.verifyNoOutstandingRequest();
            $httpBackend.verifyNoOutstandingExpectation();
          });
        });

        describe('when the save is unsuccessful', function() {
          var unsuccessfulAssessment,
              $httpBackend;

          beforeEach(function() {

            unsuccessfulAssessment = {
              id: 12,
              name: 'This is a test',
              district_id: 19,
              due_date: moment('08/01/1997', 'MM/DD/YYYY').toISOString(),
              assign: true
            };

            inject(function(_$httpBackend_) {
              $httpBackend = _$httpBackend_;
            });

            subject.district = {id: 1};

            $httpBackend.expect('PUT', '/v1/assessments/12', unsuccessfulAssessment).respond(400);
          });

          it('invokes #emitError function with the correct parameter', function() {
            spyOn(subject, 'emitError');
            subject.saveAssessment(unsuccessfulAssessment, true);
            $httpBackend.flush();
            expect(subject.emitError).toHaveBeenCalledWith('Could not save assessment');
          });

          afterEach(function() {
            $httpBackend.verifyNoOutstandingRequest();
            $httpBackend.verifyNoOutstandingExpectation();
          });
        });

        afterEach(function() {
          inputField.remove();
        });
      });
    });
  });
})();
