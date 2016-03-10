(function() {
  'use strict';
  describe('Directive: learningQuestionForm', function() {
    describe('when rendering the directive', function() {
      var element;

      beforeEach(function() {
        module('PDRClient');
        inject(function($rootScope, $injector, $compile) {
          element = angular.element('<div><learning-question-form /></div>');
          $compile(element)($rootScope);
          $rootScope.$digest();
        });
      });

      it('creates the form', function() {
        expect(element.find('form').length).toEqual(1);
      });

      it('has appropriate placeholder text', function() {
        var input = element.find('input')[0];
        expect(input.placeholder).toEqual('Enter your Learning Question here.');
      });

      it('has the appropriate input group class attached to the form', function() {
        var form = element.find('form')[0];
        expect(form.classList).toContain('input-group');
      });

      it('has the appropriate form control class attached to the input field', function() {
        var input = element.find('input')[0];
        expect(input.classList).toContain('form-control');
      });

      it('has the appropriate input group button class attached to the button', function() {
        var btn = element.find('span')[0];
        expect(btn.classList).toContain('input-group-btn');
      });
    });
  });
})();