(function() {
  'use strict';

  describe('Controller: Evidence', function() {
    var subject,
        $controller,
        $scope,
        Consensus,
        $httpBackend;
    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _$controller_, _$httpBackend_, $injector) {
        $scope = _$rootScope_.$new(true);
        $controller = _$controller_;
        Consensus = $injector.get('Consensus');
        $httpBackend = _$httpBackend_;
      });
    });

    describe('on initialization', function() {
      beforeEach(function() {
        subject = $controller('EvidenceCtrl', {
          $scope: $scope
        });
      });

      it('sets the state of hasLoadedContent to false', function() {
        expect(subject.hasLoadedContent).toBe(false);
      });
    });

    describe('#scoreValue', function() {
      beforeEach(function() {
        subject = $controller('EvidenceCtrl', {
          $scope: $scope
        });
      });
      describe('when the score is a number between 1 and 4', function() {
        it('returns the value as a string', function() {
          for(var i = 1; i <= 4; i++) {
            expect(subject.scoreValue(i)).toBe(i.toString());
          }
        });
      });

      describe('when the score is a string between 1 and 4', function() {
        it('returns the value as a string', function() {
          for(var i = 1; i <= 4; i++) {
            expect(subject.scoreValue(i.toString())).toBe(i.toString());
          }
        });
      });

      describe('when the score is 0', function() {
        it('returns the score value of S', function() {
          expect(subject.scoreValue(0)).toBe('S');
        });
      });

      describe('when the score is null', function() {
        it('returns the score value of S', function() {
          expect(subject.scoreValue(0)).toBe('S');
        });
      });

      describe('when the score is undefined', function() {
        it('returns the score value of S', function() {
          expect(subject.scoreValue(undefined)).toBe('S');
        });
      });
    });

    describe('#scoreClass', function() {
      beforeEach(function() {
        subject = $controller('EvidenceCtrl', {
          $scope: $scope
        });
      });

      describe('when the score is a number between 1 and 4', function() {
        it('returns the value prefixed with "scored-"', function() {
          for(var i = 1; i <= 4; i++) {
            expect(subject.scoreClass(i)).toBe('scored-' + i);
          }
        });
      });

      describe('when the score is a string between 1 and 4', function() {
        it('returns the value prefixed with "scored-"', function() {
          for(var i = 1; i <= 4; i++) {
            expect(subject.scoreClass(i)).toBe('scored-' + i);
          }
        });
      });

      describe('when the score is 0', function() {
        it('returns skipped', function() {
          expect(subject.scoreClass(0)).toBe('skipped');
        });
      });

      describe('when the score is null', function() {
        it('returns skipped', function() {
          expect(subject.scoreClass(0)).toBe('skipped');
        });
      });

      describe('when the score is undefined', function() {
        it('returns skipped', function() {
          expect(subject.scoreClass(undefined)).toBe('skipped');
        });
      });
    });

    describe('#loadResponses', function() {
      beforeEach(function() {
        subject = $controller('EvidenceCtrl', {
          $scope: $scope,
          Consensus: Consensus,
          $stateParams: {assessment_id: 50, response_id: 323}
        });

        subject.questionId = 1;
      });

      it('calls the right URL', function() {
        $httpBackend.expect('GET', '/v1/assessments/50/evidence/1').respond(200);
        subject.loadResponses();
        $httpBackend.flush();
      });

      afterEach(function() {
        $httpBackend.verifyNoOutstandingRequest();
        $httpBackend.verifyNoOutstandingExpectation();
      });
    });

    describe('$watch: questionId', function() {
      beforeEach(function() {
        subject = $controller('EvidenceCtrl', {
          $scope: $scope
        });
      });

      it('sets the questionId in the controller to the provided value', function() {
        $scope.$apply('questionId="177"');
        expect(subject.questionId).toBe('177');
      });
    });

    describe('$on: question-toggled', function() {
      var $rootScope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });
        subject = $controller('EvidenceCtrl', {
          $scope: $scope
        });
        spyOn(subject, 'loadResponses');
      });

      describe('when the ID being broadcast matches the current controller\'s ID', function() {
        describe('when the controller has not already been toggled', function() {
          beforeEach(function() {
            subject.questionId = '127';
            $rootScope.$broadcast('question-toggled', '127');
          });

          it('invokes #loadResponses', function() {
            expect(subject.loadResponses).toHaveBeenCalled();
          });

          it('toggled hasLoadedContent to true', function() {
            expect(subject.hasLoadedContent).toBe(true);
          });
        });

        describe('when the controller has already been toggled', function() {
          beforeEach(function() {
            subject.questionId = '127';
            subject.hasLoadedContent = true;
            $rootScope.$broadcast('question-toggled', '127');
          });

          it('does not invoke #loadResponses', function() {
            expect(subject.loadResponses).not.toHaveBeenCalled();
          });
        });
      });

      describe('when the ID being broadcast does not match the current controller\'s ID', function() {
        beforeEach(function() {
          subject.questionId = '66';
          subject.hasLoadedContent = true;
          $rootScope.$broadcast('question-toggled', '127');
        });

        it('does not invoke #loadResponses', function() {
          expect(subject.loadResponses).not.toHaveBeenCalled();
        });
      });
    });
  });
})();
