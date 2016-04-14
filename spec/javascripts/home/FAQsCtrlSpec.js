(function() {
  'use strict';
  describe('Controller: FaqsCtrl', function() {
    var subject,
        $scope,
        $location,
        $rootScope;

    beforeEach(module('PDRClient'));

    beforeEach(inject(function($controller, $injector) {
      $rootScope = $injector.get('$rootScope');
      $location = $injector.get('$location');
      $scope = $rootScope.$new();
      subject = $controller('FAQsCtrl', {
        $scope: $scope
      });
    }));

    it('sets the topic and role  param', function() {
      spyOn($location, 'search')
          .and.returnValue({topic: 'topicParam', role: 'roleParam'});
      $scope.extractQueryParams();

      expect($scope.topic).toEqual('topicParam');
      expect($scope.role).toEqual('roleParam');
    });
  });
})();

