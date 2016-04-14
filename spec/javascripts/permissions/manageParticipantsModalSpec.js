(function() {
  'use strict';

  describe('Directive: manageParticipantsModal', function() {
    var $scope,
        $compile,
        element,
        updateDataSpy;

    beforeEach(function() {
      updateDataSpy = jasmine.createSpy('ManageParticipantsModalCtrl');
      module('PDRClient', function($controllerProvider) {
        $controllerProvider.register('ManageParticipantsModalCtrl', function() {
          this.updateData = updateDataSpy;
        });
      });

      inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_.$new(true);
      });
    });

    describe('when the directive is linked in', function() {
      beforeEach(function() {
        element = angular.element('<manage-participants-modal></manage-participants-modal>');
        $compile(element)($scope);
        $scope.$digest();
      });

      it('invokes updateData from the controller', function() {
        expect(updateDataSpy).toHaveBeenCalled();
      });
    });
  });
})();