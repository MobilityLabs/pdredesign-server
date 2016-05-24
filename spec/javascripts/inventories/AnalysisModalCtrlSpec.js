(function() {
  'use strict';

  describe('Controller: AnalysisModal', function() {
    var subject,
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

      inject(function(_$state_, _$timeout_, $injector) {
        $state = _$state_;
        $timeout = _$timeout_;
        Analysis = $injector.get('Analysis');
        Inventory = $injector.get('Inventory');
      });
    });

    describe('with mock request', function() {
      var $httpBackend;

      beforeEach(function() {
        inject(function(_$httpBackend_, _$controller_) {
          $httpBackend = _$httpBackend_;
          subject = _$controller_('AnalysisModalCtrl', {
            Analysis: Analysis,
            Inventory: Inventory,
            $modalInstance: $modalInstance
          });
        });
      });

      it('creates an Analysis', function() {
        $httpBackend
            .expectPOST('/v1/inventories/42/analyses')
            .respond({});

        subject.analysis = {inventory_id: 42};
        subject.save();
        $httpBackend.flush();
      });

      it('closes the modal', function() {
        spyOn(subject, 'closeModal');
        $httpBackend
            .expectPOST('/v1/inventories/42/analyses')
            .respond({});

        subject.analysis = {inventory_id: 42}
        subject.save();
        $httpBackend.flush();
        expect(subject.closeModal).toHaveBeenCalled();
      });

      describe('handles errors', function() {
        beforeEach(function() {
          inject(function(_$controller_) {
            subject = _$controller_('AnalysisModalCtrl', {
              Analysis: Analysis,
              Inventory: Inventory,
              $modalInstance: $modalInstance
            });
          });

          $httpBackend
              .expectPOST('/v1/inventories/42/analyses')
              .respond(422, {errors: {foo: 'bar', wat: 'woot'}});

          subject.analysis = {inventory_id: 42};
          subject.save();
          $httpBackend.flush();
        });

        it('populates alerts', function() {
          expect(subject.alerts).toContain({type: 'danger', msg: 'foo : bar'});
        });

        it('is dismisses alerts', function() {
          expect(subject.alerts.length).toBe(2);
          subject.closeAlert(0);
          expect(subject.alerts.length).toBe(1);
        });
      });
    });
  });
})();
