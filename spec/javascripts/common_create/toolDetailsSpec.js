(function() {
  'use strict';

  describe('Directive: toolDetails', function() {
    var element,
        isolatedScope;

    beforeEach(function() {
      module('PDRClient');
      inject(function($rootScope, $compile) {
        element = angular.element('<tool-details></tool-details>');
        $compile(element)($rootScope);
        $rootScope.$digest();
      });
      isolatedScope = element.isolateScope();

    });

    it('binds datetimepicker to the scope', function() {
      expect(isolatedScope.datetime).not.toBeUndefined();
    });

    it('invokes the change event', function() {
      var spy = jasmine.createSpy('spy');
      element.on('change', spy);
      isolatedScope.datetime.trigger('dp.change');
      expect(spy).toHaveBeenCalled();
    });
  });
})();