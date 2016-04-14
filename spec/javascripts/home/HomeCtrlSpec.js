(function() {
  'use strict';
  describe('Controller: HomeCtrlSpec', function() {
    var subject,
        $scope,
        $state;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$state_, _$rootScope_) {
        $state = _$state_;
        $scope = _$rootScope_.$new(true);
        subject = _$controller_('HomeCtrl', {
          $scope: $scope
        });
      });
    });

    it('redirects to /home when logged in', function() {
      window.$state = $state;
      $state.go('root');

      spyOn($state, 'go');
      $scope.user = {id: 1};
      $scope.$digest();
      expect($state.go).toHaveBeenCalledWith('home');
    });
  });
})();

