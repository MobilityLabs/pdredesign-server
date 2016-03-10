describe('Directive: sharedAssessmentPriority', function() {
  var element,
      isolatedScope,
      $scope,
      $compile,
      $httpBackend;

  beforeEach(module('PDRClient'));

  beforeEach(inject(function($rootScope, $injector) {
    $scope   = $rootScope.$new({});
    $compile = $injector.get('$compile');
    $httpBackend = $injector.get('$httpBackend');

    $httpBackend.when('GET', '/v1/assessments/shared/token-123/priorities').respond([]);

    element = angular.element("<shared-assessment-priority data-token='token-123'></shared-assessment-priority>");
    $compile(element)($scope);
    $scope.$digest();

    isolatedScope = element.isolateScope();
    $httpBackend.flush();
  }));

  it('sets token correctly', function(){
    expect(isolatedScope.token).toEqual('token-123');
  });
});
