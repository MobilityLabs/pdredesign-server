describe('Directive: responseQuestions', function() {
  var $scope,
      element,
      isolatedScope,
      Response,
      $compile,
      $timeout,
      $httpBackend,
      $q;
  var score1    = {id: 1, evidence: "hello", value: 1, editMode: null};
  var question1 = {id: 1, score: score1 };
  var answer1   = {id: 1, value: 2};

  beforeEach(module('PDRClient'));

  beforeEach(inject(function($rootScope, $injector) {
    $scope   = $rootScope.$new();
    $compile = $injector.get('$compile');
    $timeout = $injector.get("$timeout");
    $q = $injector.get('$q');
    $httpBackend = $injector.get('$httpBackend');
    Response = $injector.get('Response');

    element = angular.element('<response-questions data-assessment-id=1 data-response-id=1></response-questions>');
    $compile(element)($scope);
    $scope.$digest();
    isolatedScope = element.isolateScope();

  }));

  it('isConsensus will be false by default ', function() {
    expect(isolatedScope.isConsensus).toEqual(false);
  });

  it('save button is not disabled with evidence present', function() {
    expect(isolatedScope.invalidEvidence(question1)).toEqual(false)
  });

  it('save button is disabled with no evidence', function() {
    var score2 = {id: 1, evidence: "", value: 1, editMode: null};
    var question2 = {id: 1, score: score2 };
    expect(isolatedScope.invalidEvidence(question2)).toEqual(true)
  });

  describe('#ResponseGET', function() {
    it('gets data on callback and sets categories', function() {
      $httpBackend.whenGET('/v1/assessments/1/responses/1/slim').respond({categories: [1,2,3]});
      $timeout.flush();
      $httpBackend.flush();
      expect(isolatedScope.categories).toEqual([1,2,3]);
    });

  });
});
