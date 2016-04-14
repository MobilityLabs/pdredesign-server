(function() {
  'use strict';
  describe('Directive: disableEntry', function() {
    var element,
        $scope,
        $compile;

    function createElement(hasAccess){
      $scope.entity.has_access = hasAccess;
      $compile(element)($scope);
      $scope.$digest();
      return element;
    }

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _$compile_) {
        $scope = _$rootScope_.$new(true);
        $compile = _$compile_;
        $scope.entity = {};
        element = angular.element("<div class='disable-entry'>");
      });
    });

    describe('when has_access is false', function() {
      beforeEach(function() {
        element = createElement(false);
      });

      it('sets opacity to 0.5', function() {
        expect(element.css('opacity')).toEqual('0.5');
      });
    });

    describe('when has_access is true', function() {
      beforeEach(function() {
        element = createElement(true);
      });

      it('keeps opacity 1', function() {
        expect(element.css('opacity')).toEqual('1');
      });
    });
  });
})();
