(function() {
  'use strict';

  describe('Controller: InventoryEdit', function() {
    var controller;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$rootScope_) {
        var scope = _$rootScope_.$new(true);
        controller = _$controller_('InventoryEditCtrl', {
          $scope: scope,
          inventory: {
            id: 1
          }
        });
      });
    });

    it('binds inventory to the view model', function() {
      expect(controller.inventory).toEqual({id: 1});
    });
  });
})();
