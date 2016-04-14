(function() {
  'use strict';

  describe('Directive: faqs', function() {
    var element,
        isolatedScope,
        $scope,
        $compile,
        $timeout,
        $state,
        $httpBackend;

    beforeEach(module('PDRClient'));
    beforeEach(inject(function($rootScope, $injector) {
      $scope = $rootScope.$new({});
      $compile = $injector.get('$compile');
      $timeout = $injector.get('$timeout');
      $state = $injector.get('$state');
      $httpBackend = $injector.get('$httpBackend');

      element = angular.element("<faqs></faqs>");
      $compile(element)($scope);
      $scope.$digest();

      isolatedScope = element.isolateScope();
    }));

    it('sets the topic and subject of the faq', function() {
      element = angular.element("<faqs topic='topic' role='role'></faqs>");
      $compile(element)($scope);
      $scope.$digest();
      isolatedScope = element.isolateScope();

      expect(isolatedScope.selectedTopic).toEqual('topic');
      expect(isolatedScope.selectedRole).toEqual('role');
    });

    it('updates the location when the topic is changed', function() {
      spyOn($state, 'transitionTo');
      isolatedScope.selectedTopic = 'newTopic';
      isolatedScope.selectedRole = 'newRole';
      isolatedScope.updatedSelection();

      expect($state.transitionTo)
          .toHaveBeenCalledWith('faqs', {role: 'newRole', topic: 'newTopic'});

    });

    it('it gets FAQs from the backend endpoitn', function() {
      $httpBackend.expectGET('/v1/faqs').respond([{expected: true}]);
      $timeout.flush();
    });

    it('#toggleQuestion toggles a targest visibility', function() {
      var target = {visible: false};
      isolatedScope.toggleQuestion(target);
      expect(target.visible).toEqual(true);
    });

    it('#uniq_faq_property returns a uniq property from categories', function() {
      var categories = [
        {questions: [{role: 'first'}, {role: 'second'}, {role: 'first'}]},
        {questions: [{role: 'first'}, {role: 'second'}, {role: 'third'}]},
      ];
      expect(isolatedScope.uniq_faq_property(categories, 'role'))
          .toEqual(['first', 'second', 'third']);
    });
  });
})();