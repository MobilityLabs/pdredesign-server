(function() {
  'use strict';

  describe('Controller: AssessmentReportCtrl', function() {
    var subject, scope;

    beforeEach(module('PDRClient'));

    beforeEach(inject(function($injector, $controller, $rootScope) {

      scope = $rootScope.$new();
      subject  = $controller('AssessmentReportCtrl', {
        $scope: scope
      });
    }));

    it('isFacilitator should return true', function() {
      scope.assessment.owner = true
      expect(scope.isFacilitator()).toEqual(true)
    });

    it('isFacilitator should return false for the non-facilitator', function() {
      scope.assessment.owner = false
      expect(scope.isFacilitator()).toEqual(false)
    });

    it('canEditPriorities should return false for the non-facilitator', function() {
      scope.assessment.owner = false
      expect(scope.canEditPriorities()).toEqual(false)
    });

  });
})();
