(function() {
  'use strict';

  describe('Directive: inventoryModal', function() {

    var $scope,
        $compile,
        element,
        isolatedScope;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _$compile_) {
        $scope = _$rootScope_.$new(true);
        $compile = _$compile_;
      });

      element = angular.element('<inventory-modal></inventory-modal>');
      $compile(element)($scope);
      $scope.$digest();
      isolatedScope = element.isolateScope();
    });

    it('binds datetimepicker to the scope', function() {
      expect(isolatedScope.datetime).not.toBeUndefined();
    });

    it('invokes the change event on dp.change', function() {
      var spy = jasmine.createSpy('spy');
      element.on('change', spy);
      isolatedScope.datetime.trigger('dp.change');
      expect(spy).toHaveBeenCalled();
    });
  });
})();
