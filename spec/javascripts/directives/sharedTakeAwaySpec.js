describe('Directive: sharedTakeAway', function() {
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

    $httpBackend.when('GET', '/v1/assessments/shared/token-123').respond({
      id: 1,
      is_facilitator: true,
    });

    element = angular.element("<shared-take-away token='token-123'></shared-take-away>");
    $compile(element)($scope);
    $scope.$digest();

    isolatedScope = element.isolateScope();
    $httpBackend.flush();
  }));

    it('sets token correctly', function(){
      expect(isolatedScope.token).toEqual('token-123');
    });

    it('isFacilitator returns true', function(){
      expect(isolatedScope.isFacilitator()).toEqual(true);
    });
});
