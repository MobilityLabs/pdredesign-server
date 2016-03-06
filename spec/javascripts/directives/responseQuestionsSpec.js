(function() {
  'use strict';

  xdescribe('Directive: responseQuestions', function() {
    var $scope,
        element,
        isolatedScope,
        Response,
        $compile,
        $timeout,
        $httpBackend,
        $stateParams,
        $q;
    var score1 = {id: 1, evidence: "hello", value: 1, editMode: null};
    var question1 = {id: 1, score: score1};
    var answer1 = {id: 1, value: 2};

    beforeEach(module('PDRClient'));

    beforeEach(inject(function($rootScope, $injector) {
      $scope = $rootScope.$new(true);
      $compile = $injector.get('$compile');
      $timeout = $injector.get("$timeout");
      $q = $injector.get('$q');
      $httpBackend = $injector.get('$httpBackend');
      $stateParams = {assessment_id: 1, response_id: 1};
      Response = $injector.get('Response');

      $scope.categories = [1];

      element = angular.element('<response-questions />');
      $compile(element)($scope);
      $scope.$digest();
      isolatedScope = element.isolateScope();

    }));
  });
})();
