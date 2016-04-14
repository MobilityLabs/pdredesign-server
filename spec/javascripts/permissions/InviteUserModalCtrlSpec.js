(function() {
  'use strict';

  describe('Controller: InviteUserModal', function() {
    var subject,
        $scope,
        $stateParams,
        UserInvitation;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _$controller_, $injector) {
        $scope = _$rootScope_.$new(true);
        $stateParams = {id: 1};
        UserInvitation = $injector.get('UserInvitation');

        subject = _$controller_('InviteUserModalCtrl', {
          $scope: $scope,
          $stateParams: $stateParams,
          UserInvitation: UserInvitation
        });
      });
    });

    describe('with mock request', function() {
      var $httpBackend;
      beforeEach(function() {
        inject(function(_$httpBackend_) {
          $httpBackend = _$httpBackend_;
        });

        spyOn($scope, '$emit');
        spyOn(subject, 'closeModal');

        $httpBackend
            .expectPOST('/v1/assessments/1/user_invitations', {first_name: 'test'})
            .respond({});
      });

      it('creates a UserInvitation', function() {
        subject.createInvitation({first_name: 'test'});
        $httpBackend.flush();
      });

      it('emits update_participants', function() {
        subject.createInvitation({first_name: 'test'});
        $httpBackend.flush();
        expect($scope.$emit).toHaveBeenCalledWith('update_participants');
      });

      it('closes the invite modal', function() {
        subject.createInvitation({first_name: 'test'});
        $httpBackend.flush();
        expect(subject.closeModal).toHaveBeenCalled();
      });
    });

    describe('#createInvitation', function() {
      describe('with sendInvite set to "true"', function() {
        var $q;
        beforeEach(function() {
          inject(function(_$q_) {
            $q = _$q_;
          });
          spyOn(UserInvitation, 'create').and.callFake(function() {
            var deferred = $q.defer();
            deferred.resolve({});
            return {$promise: deferred.promise};
          });
          $scope.sendInvite = 'true';
        });

        it('calls UserInvitation#create with the right parameters', function() {
          var userObject = {first_name: 'test'};
          subject.createInvitation(userObject);
          expect(UserInvitation.create).toHaveBeenCalledWith({assessment_id: 1}, {
            first_name: 'test',
            send_invite: true
          });
        });
      });

      describe('with sendInvite set to "false"', function() {
        var $q;
        beforeEach(function() {
          inject(function(_$q_) {
            $q = _$q_;
          });
          spyOn(UserInvitation, 'create').and.callFake(function() {
            var deferred = $q.defer();
            deferred.resolve({});
            return {$promise: deferred.promise};
          });
          $scope.sendInvite = 'false';
        });

        it('calls UserInvitation#create with the right parameters', function() {
          var userObject = {first_name: 'test'};
          subject.createInvitation(userObject);
          expect(UserInvitation.create).toHaveBeenCalledWith({assessment_id: 1}, {
            first_name: 'test'
          });
        });
      });
    })
  });
})();