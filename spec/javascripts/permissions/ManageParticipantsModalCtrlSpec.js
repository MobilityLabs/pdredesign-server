(function() {
  'use strict';

  describe('Controller: ManageParticipantsModal', function() {
    var subject,
        $scope,
        $window,
        $stateParams,
        AssessmentPermission,
        Participant;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _$window_, _$controller_, $injector) {
        $scope = _$rootScope_.$new(true);
        $window = _$window_;
        $stateParams = {id: 1};

        AssessmentPermission = $injector.get('AssessmentPermission');
        Participant = $injector.get('Participant');

        subject = _$controller_('ManageParticipantsModalCtrl', {
          $scope: $scope,
          $window: $window,
          $stateParams: $stateParams,
          AssessmentPermission: AssessmentPermission,
          Participant: Participant
        });
      });
    });

    describe('#hideModal', function() {
      beforeEach(function() {
        spyOn($scope, '$emit');
      });

      it('emits the close-manage-participants-modal event', function() {
        subject.hideModal();
        expect($scope.$emit).toHaveBeenCalledWith('close-manage-participants-modal');
      });
    });

    describe('#humanPermissionName', function() {
      it('it converts an empty string to None', function() {
        expect(subject.humanPermissionName('')).toEqual('None');
      });

      it('returns the string as itself', function() {
        expect(subject.humanPermissionName('Human')).toEqual('Human');
      });
    });

    describe('#updateParticipants', function() {
      beforeEach(function() {
        spyOn(Participant, 'all');
      });

      it('invokes Participant.all', function() {
        subject.updateParticipants();
        expect(Participant.all).toHaveBeenCalledWith({assessment_id: 1});
      });
    });

    describe('#updateAssessmentUsers', function() {
      beforeEach(function() {
        spyOn(AssessmentPermission, 'users');
      });

      it('invokes AssessmentPermission.users', function() {
        subject.updateAssessmentUsers();
        expect(AssessmentPermission.users).toHaveBeenCalledWith({assessment_id: 1});
      });
    });

    describe('#updateAccessRequests', function() {
      beforeEach(function() {
        spyOn(AssessmentPermission, 'query');
      });

      it('invokes AssessmentPermission.query', function() {
        subject.updateAccessRequests();
        expect(AssessmentPermission.query).toHaveBeenCalledWith({assessment_id: 1});
      });
    });

    describe('#performPermissionsAction', function() {
      var $q;

      beforeEach(inject(function(_$q_) {
        $q = _$q_;
      }));

      it('calls the given function', function() {
        this.performExample = function() {
        };

        spyOn(this, 'performExample').and.callFake(function() {
          var deferred = $q.defer();
          deferred.resolve(true);
          return {$promise: deferred.promise};
        });

        subject.performPermissionsAction(this.performExample);
        expect(this.performExample).toHaveBeenCalled();

      });
    });

    describe('#denyRequest', function() {
      describe('when the user declines the action', function() {
        beforeEach(function() {
          spyOn($window, 'confirm').and.returnValue(false);
          spyOn(subject, 'performPermissionsAction');
        });

        it('does nothing', function() {
          subject.denyRequest({});
          expect(subject.performPermissionsAction).not.toHaveBeenCalled();
        });
      });

      describe('when the user accepts the action', function() {
        var options = {
          id: 124,
          email: 'foo@example.com'
        };

        beforeEach(function() {
          spyOn($window, 'confirm').and.returnValue(true);
          spyOn(subject, 'performPermissionsAction');
        });

        it('invokes performPermissionAction with the right parameters', function() {
          subject.denyRequest(options);
          expect(subject.performPermissionsAction)
              .toHaveBeenCalledWith(AssessmentPermission.deny, options.id, options.email);
        });
      });
    });


    describe('#acceptRequest', function() {
      describe('when the user declines the action', function() {
        beforeEach(function() {
          spyOn($window, 'confirm').and.returnValue(false);
          spyOn(subject, 'performPermissionsAction');
        });

        it('does nothing', function() {
          subject.acceptRequest({});
          expect(subject.performPermissionsAction).not.toHaveBeenCalled();
        });
      });

      describe('when the user accepts the action', function() {
        var options = {
          id: 124,
          email: 'foo@example.com'
        };

        beforeEach(function() {
          spyOn($window, 'confirm').and.returnValue(true);
          spyOn(subject, 'performPermissionsAction');
        });

        it('invokes performPermissionAction with the right parameters', function() {
          subject.acceptRequest(options);
          expect(subject.performPermissionsAction)
              .toHaveBeenCalledWith(AssessmentPermission.accept, options.id, options.email);
        });
      });
    });

    xdescribe('#savePermissions', function() {
      // skipped due to us wanting to revisit how we're extracting the data from that form!
    });
  });
})();
