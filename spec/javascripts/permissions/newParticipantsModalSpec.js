(function() {
  'use strict';

  describe('Directive: newParticipantsModal', function() {
    var $scope,
        $compile,
        element,
        updateParticipantsSpy;

    beforeEach(function() {
      updateParticipantsSpy = jasmine.createSpy('updateParticipants');
      module('PDRClient', function($controllerProvider) {
        $controllerProvider.register('NewParticipantsModalCtrl', function() {
          this.updateParticipants = updateParticipantsSpy;
        });
      });

      inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_.$new(true);
      });
    });

    describe('when the directive is linked in', function() {
      beforeEach(function() {
        element = angular.element('<new-participants-modal></new-participants-modal>');
        $compile(element)($scope);
        $scope.$digest();
      });

      it('invokes updateParticipants from the controller', function() {
        expect(updateParticipantsSpy).toHaveBeenCalled();
      });
    });
  });
})();