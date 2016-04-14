(function() {
  'use strict';

  describe('Controller: NavigationCtrl', function() {
    var subject,
        scope,
        SessionService;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$rootScope_, _$controller_, $injector) {
        scope = _$rootScope_.$new(true);
        SessionService = $injector.get('SessionService');
        subject = _$controller_('NavigationCtrl', {
          $scope: scope
        });
      })
    });

    it('give the active class for current state', function() {
      scope.currentLocation = 'home';
      expect(scope.activeClassFor('home')).toEqual('active');
      expect(scope.activeClassFor('current_state')).toEqual('');

      scope.currentLocation = 'current_state';
      expect(scope.activeClassFor('home')).toEqual('');
      expect(scope.activeClassFor('current_state')).toEqual('active');
    });

    it('update template when $emit session_updated', function() {
      spyOn(SessionService, 'setUserTemplate');
      scope.user = {};
      scope.$emit('session_updated');
      expect(SessionService.setUserTemplate).toHaveBeenCalled();
    });
  });
})();

