(function() {
  'use strict';

  describe('Controller: ResponseQuestionCtrl', function() {
    var controller,
        $scope,
        rootScope,
        $timeout,
        $httpBackend;

    beforeEach(function() {
      module('PDRClient');
      inject(function($controller, $rootScope, $injector) {
        rootScope = $rootScope;
        $scope = rootScope.$new(true);
        $httpBackend = $injector.get('$httpBackend');
        $timeout = $injector.get('$timeout');
        controller = $controller('ResponseQuestionCtrl', {
          $scope: $scope,
          $stateParams: {assessment_id: 1, response_id: 1}
        });
      });
    });

    describe('on initialization', function() {
      it('gets data on callback and sets categories', function() {
        $httpBackend.when('GET', '/v1/assessments/1/responses/1/slim').respond({categories: [1, 2, 3]});
        $timeout.flush();
        $httpBackend.flush();
        expect($scope.categories).toEqual([1, 2, 3]);
      });
    });

    describe('after initialization', function() {
      var score1 = {id: 1, evidence: "hello", value: 1, editMode: null};
      var question1 = {id: 1, score: score1};

      beforeEach(function() {
        $httpBackend.when('GET', '/v1/assessments/1/responses/1/slim').respond({categories: [1, 2, 3]});
      });

      it('isConsensus will be false by default ', function() {
        expect($scope.isConsensus).toEqual(false);
      });

      it('save button is not disabled with evidence present', function() {
        expect($scope.invalidEvidence(question1)).toEqual(false)
      });

      it('save button is disabled with no evidence', function() {
        var score2 = {id: 1, evidence: "", value: 1, editMode: null};
        var question2 = {id: 1, score: score2};
        expect($scope.invalidEvidence(question2)).toEqual(true)
      });

    });

    afterEach(function() {
      $httpBackend.verifyNoOutstandingExpectation();
    });
  });
})();
