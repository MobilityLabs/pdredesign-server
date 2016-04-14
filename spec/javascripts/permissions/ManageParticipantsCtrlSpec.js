(function() {
  'use strict';

  describe('Controller: ManageParticipants', function() {
    var subject,
        $modal,
        $scope;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _$controller_, _$modal_) {
        $scope = _$rootScope_.$new(true);
        $modal = _$modal_;

        subject = _$controller_('ManageParticipantsCtrl', {
          $scope: $scope,
          $modal: $modal
        });
      });
    });

    describe('#showAddParticipants', function() {
      var modalOptions;

      beforeEach(function() {
        modalOptions = {
          template: '<manage-participants-modal></manage-participants-modal>',
          scope: $scope,
          size: 'lg'
        };
        spyOn($modal, 'open');
      });

      it('calls $modal.open with the correct parameters', function() {
        subject.showAddParticipants();
        expect($modal.open).toHaveBeenCalledWith(modalOptions);
      });
    });

    describe('#hideModal', function() {
      var dismissSpy;
      beforeEach(function() {
        dismissSpy = jasmine.createSpy('dismiss');
        subject.modalInstance = {dismiss: dismissSpy};
      });

      it('calls dismiss with the correct parameter', function() {
        subject.hideModal();
        expect(dismissSpy).toHaveBeenCalledWith('cancel');
      });
    });

    describe('$on: close-manage-participants-modal', function() {
      var $rootScope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });
        spyOn(subject, 'hideModal');
      });

      it('calls #hideModal', function() {
        $rootScope.$broadcast('close-manage-participants-modal');
        expect(subject.hideModal).toHaveBeenCalled();
      });
    });
  });
})();
