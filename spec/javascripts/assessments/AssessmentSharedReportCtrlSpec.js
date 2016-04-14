(function() {
  'use strict';

  describe('Controller: AssessmentSharedReportCtrl', function() {
    var subject, scope;
    beforeEach(module('PDRClient'));

    beforeEach(inject(function($injector, $controller, $rootScope, $stateParams) {
      var $httpBackend = $injector.get('$httpBackend');
      $httpBackend.when('GET', '/v1/assessments/shared/token-123').respond({
        id: 1
      });
      $httpBackend.when('GET', '/v1/assessments/shared/token-123/report').respond({
        id: 1
      });
      $stateParams.token = "token-123";
      scope = $rootScope.$new();
      subject  = $controller('AssessmentSharedReportCtrl', {
        $stateParams: $stateParams,
        $scope: scope
      });
      scope.$apply();
    }));

    it('loads report', function() {
      expect(scope.report).not.toBeNull();
    });

    it('loads assessment', function() {
      expect(scope.assessment).not.toBeNull();
    });
  });
})();
