(function() {
  'use strict';

  describe('Directive: manageParticipants', function() {
    var $scope,
        $compile,
        element,
        showAddParticipantsSpy;

    beforeEach(function() {
      showAddParticipantsSpy = jasmine.createSpy('ManageParticipantsCtrlSpy');
      module('PDRClient', function($controllerProvider) {
        $controllerProvider.register('ManageParticipantsCtrl', function() {
          this.showAddParticipants = showAddParticipantsSpy;
        });

      });
      inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_.$new(true);
      });
    });

    describe('when autoShow is true', function() {
      beforeEach(function() {
        element = angular.element('<manage-participants auto-show="true"></manage-participants>');
        $compile(element)($scope);
        $scope.$digest();
      });

      it('calls #showAddParticipants on the ManageParticipantsCtrl', function() {
        expect(showAddParticipantsSpy).toHaveBeenCalled();
      });
    });

    describe('when autoShow is false', function() {
      beforeEach(function() {
        element = angular.element('<manage-participants auto-show="false"></manage-participants>');
        $compile(element)($scope);
        $scope.$digest();
      });

      it('calls #showAddParticipants on the ManageParticipantsCtrl', function() {
        expect(showAddParticipantsSpy).not.toHaveBeenCalled();
      });
    });

    describe('when autoShow is undefined', function() {
      beforeEach(function() {
        element = angular.element('<manage-participants></manage-participants>');
        $compile(element)($scope);
        $scope.$digest();
      });

      it('calls #showAddParticipants on the ManageParticipantsCtrl', function() {
        expect(showAddParticipantsSpy).not.toHaveBeenCalled();
      });
    });
  });
})();
