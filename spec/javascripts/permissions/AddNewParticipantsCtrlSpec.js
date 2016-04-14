(function() {
  'use strict';

  describe('Controller: AddNewParticipants', function() {
    var subject,
        $scope,
        $modal;

    beforeEach(function() {
      module('PDRClient');

      inject(function(_$rootScope_, _$modal_, _$controller_) {
        $scope = _$rootScope_.$new(true);
        $modal = _$modal_;

        subject = _$controller_('AddNewParticipantsCtrl', {
          $scope: $scope,
          $modal: $modal
        });
      });
    });

    describe('#showNewParticipantsModal', function() {
      beforeEach(function() {
        spyOn($modal, 'open');
      });

      it('invokes the modal with the right parameters', function() {
        subject.showNewParticipantsModal();
        expect($modal.open).toHaveBeenCalledWith({
          template: '<new-participants-modal send-invite="' + $scope.sendInvite + '"></new-participants-modal>',
          scope: $scope,
          size: 'lg'
        });
      });
    });

    describe('$on: close-new-participants-modal', function() {
      var $rootScope,
          dismissSpy;

      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });

        dismissSpy = jasmine.createSpy('dismiss');
        subject.newParticipantsModal = {dismiss: dismissSpy};

        $rootScope.$broadcast('close-new-participants-modal');
      });

      it('invokes the dismiss method in the newParticipantsModal', function() {
        expect(dismissSpy).toHaveBeenCalledWith('cancel');
      });
    });
  });
})();
