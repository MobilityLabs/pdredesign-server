(function() {
  'use strict';

  describe('Controller: AnalysisModal', function() {
    var subject,
        $scope,
        $q,
        $state,
        $timeout,
        $modalInstance,
        modalInstanceClose,
        Analysis,
        Inventory,
        preSelectedInventory;

    beforeEach(function() {
      modalInstanceClose = jasmine.createSpy('modalInstanceClose');
      $modalInstance = {
        close: modalInstanceClose
      };

      preSelectedInventory = jasmine.createSpy('preSelectedInventory');
      module('PDRClient', function($provide) {
        $provide.value('$modalInstance', function() {
          return $modalInstance;
        });

        $provide.value('preSelectedInventory', function() {
          return preSelectedInventory;
        });
      });

      inject(function(_$state_, _$timeout_, _$rootScope_, _$q_, $injector) {
        $state = _$state_;
        $scope = _$rootScope_.$new(true);
        $timeout = _$timeout_;
        $q = _$q_;
        Analysis = $injector.get('Analysis');
        Inventory = $injector.get('Inventory');
      });
    });

    describe('with mock request', function() {
      var $rootScope;

      beforeEach(function() {
        inject(function(_$rootScope_, _$controller_) {
          $rootScope = _$rootScope_;
          subject = _$controller_('AnalysisModalCtrl', {
            $scope: $scope,
            Analysis: Analysis,
            Inventory: Inventory,
            $modalInstance: $modalInstance
          });
        });
      });
      describe('when successful', function() {
        beforeEach(function() {
          spyOn(Analysis, 'create').and.returnValue({$promise: $q.when({})});
          subject.analysis = {inventory_id: 42};
          spyOn(subject, 'closeModal');

          subject.save();
          $rootScope.$apply();
        });

        it('creates an Analysis', function() {
          expect(Analysis.create).toHaveBeenCalledWith(null, {inventory_id: 42, deadline: 'Invalid date'});
        });

        it('closes the modal', function() {
          expect(subject.closeModal).toHaveBeenCalled();
        });
      });

      describe('when unsuccessful and generates errors', function() {
        beforeEach(function() {
          spyOn(Analysis, 'create').and.returnValue({
            $promise: $q.reject({
              data: {errors: {foo: 'bar', wat: 'woot'}}
            })
          });
          subject.analysis = {inventory_id: 42};
          subject.save();
          
          $rootScope.$apply();
        });

        it('populates alerts', function() {
          expect(subject.alerts).toContain({type: 'danger', msg: 'foo : bar'});
        });

        it('dismisses alerts', function() {
          expect(subject.alerts.length).toBe(2);
          subject.closeAlert(0);
          expect(subject.alerts.length).toBe(1);
        });
      });
    });
  });
})();
