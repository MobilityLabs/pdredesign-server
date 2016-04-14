(function() {
  'use strict';

  describe('Controller: InviteUser', function() {
    var subject,
        $scope,
        $modal;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$rootScope_, _$modal_) {
        $scope = _$rootScope_.$new(true);
        $modal = _$modal_;
        subject = _$controller_('InviteUserCtrl', {
          $scope: $scope,
          $modal: $modal
        });
      });
    });

    describe('#showInviteUserModal', function() {
      beforeEach(function() {
        spyOn($modal, 'open');
        $scope.sendInvite = 'true';
        $scope.role = 'this is a very very long role';
      });

      it('creates a modal with the right parameters', function() {
        subject.showInviteUserModal();
        expect($modal.open).toHaveBeenCalledWith({
          template: '<invite-user-modal send-invite="true" role="this is a very very long role"></invite-user-modal>',
          scope: $scope
        });
      });
    });

    describe('$on: close-invite-modal', function() {
      var modalInstanceSpy = jasmine.createSpy('modalInstance');
      var $rootScope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });
        subject.modalInstance = {dismiss: modalInstanceSpy};
      });

      it('invokes the dismiss functionality', function() {
        $rootScope.$broadcast('close-invite-modal');
        expect(modalInstanceSpy).toHaveBeenCalledWith('cancel');
      });
    });
  });
})();
