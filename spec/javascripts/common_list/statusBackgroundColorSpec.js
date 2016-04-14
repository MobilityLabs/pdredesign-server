(function() {
  'use strict';

  describe('Directive: statusBackgroundColor', function() {
    var element,
        $scope,
        $compile;

    function createElement(status){
      $scope.entity.status =  status;
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
        element = angular.element('<div class="status-background-color"></div>');
      });
    });

    describe('when setting the entity status to draft', function() {
      beforeEach(function() {
        element = createElement('draft');
      });

      it('adds the draft-state CSS class', function() {
        expect(element.hasClass('draft-state')).toBe(true);
      });
    });

    describe('when setting the entity status to assessment', function() {
      beforeEach(function() {
        element = createElement('assessment');
      });

      it('adds the assessment-state CSS class', function() {
        expect(element.hasClass('assessment-state')).toBe(true);
      });
    });

    describe('when setting the entity status to consensus', function() {
      beforeEach(function() {
        element = createElement('consensus');
      });

      it('adds the consensus-state CSS class', function() {
        expect(element.hasClass('consensus-state')).toBe(true);
      });
    });

    describe('when leaving the entity status undefined', function() {
      beforeEach(function() {
        element = createElement(undefined);
      });

      it('adds the consensus-state CSS class', function() {
        expect(element.hasClass('consensus-state')).toBe(true);
      });
    });
  });
})();
