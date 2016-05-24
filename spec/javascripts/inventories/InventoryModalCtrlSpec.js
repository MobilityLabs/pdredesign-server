(function() {
  'use strict';

  describe('Controller: InventoryModal', function() {
    var $scope,
        $timeout,
        $location,
        SessionService,
        Inventory,
        $modalInstance,
        modalInstanceClose,
        controller;

    beforeEach(function() {
      modalInstanceClose = jasmine.createSpy('modalInstanceClose');
      $modalInstance = {
        close: modalInstanceClose
      };

      module('PDRClient', function($provide) {
        $provide.value('$modalInstance', function() {
          return $modalInstance;
        });
      });

      inject(function(_$timeout_, _$location_, _$controller_, $injector) {
        $timeout = _$timeout_;
        $location = _$location_;
        SessionService = $injector.get('SessionService');
        Inventory = $injector.get('Inventory');
        controller = _$controller_('InventoryModalCtrl', {
          $modalInstance: $modalInstance,
          $timeout: $timeout,
          $location: $location,
          SessionService: SessionService,
          Inventory: Inventory
        });
      });
    });

    describe('#close', function() {
      it('delegates to $modalInstance', function() {
        controller.close();
        expect(modalInstanceClose).toHaveBeenCalledWith('cancel');
      });
    });

    describe('#error', function() {

      it('pushes elements to the alerts array', function() {
        controller.error('this is an error!');
        expect(controller.alerts).toContain({type: 'danger', msg: 'this is an error!'});
      });
    });

    describe('#closeAlert', function() {
      beforeEach(function() {
        controller.alerts = [
          {type: 'danger', msg: 'foo'},
          {type: 'danger', msg: 'bar'}
        ];
      });

      it('removes the right entry from the alerts list', function() {
        controller.closeAlert(0);
        expect(controller.alerts).not.toContain({type: 'danger', msg: 'foo'});
      });

      it('only contains one alert', function() {
        controller.closeAlert(0);
        expect(controller.alerts.length).toEqual(1);
      });
    });

    describe('#createInventory', function() {
      var $httpBackend;

      beforeEach(function() {
        inject(function(_$httpBackend_) {
          $httpBackend = _$httpBackend_;
        });
      });

      describe('when successfully creating an inventory', function() {
        beforeEach(function() {
          $httpBackend.expect('POST', '/v1/inventories', {
                inventory: {
                  name: 'foo',
                  deadline: '09/09/3999',
                  district_id: 7
                }
              })
              .respond({id: 17});
        });

        it('calls the close function', function() {
          spyOn(controller, 'close');
          controller.createInventory({
            name: 'foo',
            deadline: '09/09/3999',
            district_id: 7
          });
          $httpBackend.flush();
          expect(controller.close).toHaveBeenCalled();
        });

        it('uses $location to send the user to the right place', function() {
          spyOn(controller, 'close');
          spyOn($location, 'url');
          controller.createInventory({
            name: 'foo',
            deadline: '09/09/3999',
            district_id: 7
          });
          $httpBackend.flush();
          expect($location.url).toHaveBeenCalledWith('/inventories/17/assign');
        });

        afterEach(function() {
          $httpBackend.verifyNoOutstandingExpectation();
          $httpBackend.verifyNoOutstandingRequest();
        });
      });

      describe('when unsuccessfully creating an inventory', function() {
        beforeEach(function() {
          $httpBackend.expect('POST', '/v1/inventories', {
                inventory: {
                  name: 'foo',
                  deadline: '01/01/2001',
                  district_id: 7
                }
              })
              .respond(400, {
                    errors: {
                      denial: ['for test purposes'],
                      another_reason: ['for test reasons']
                    }
                  }
              );
        });

        it('calls the error method with the correct arguments', function() {
          spyOn(controller, 'error');
          controller.createInventory({
            name: 'foo',
            deadline: '01/01/2001',
            district_id: 7
          });
          $httpBackend.flush();
          expect(controller.error).toHaveBeenCalledWith('denial : for test purposes');
          expect(controller.error).toHaveBeenCalledWith('another_reason : for test reasons');
        });

        afterEach(function() {
          $httpBackend.verifyNoOutstandingExpectation();
          $httpBackend.verifyNoOutstandingRequest();
        });
      });
    });

    describe('#noDistrict', function() {
      describe('when the user does not have any districts', function() {
        beforeEach(function() {
          spyOn(SessionService, 'getCurrentUser').and.returnValue({district_ids: []});
          inject(function(_$controller_) {
            controller = _$controller_('InventoryModalCtrl', {
              $scope: $scope,
              $timeout: $timeout,
              $location: $location,
              SessionService: SessionService,
              Inventory: Inventory
            });
          });
        });

        it('returns true', function() {
          expect(controller.noDistrict()).toEqual(true);
        });
      });

      describe('when the user does not have the district_ids property', function() {
        beforeEach(function() {
          spyOn(SessionService, 'getCurrentUser').and.returnValue({});
          inject(function(_$controller_) {
            controller = _$controller_('InventoryModalCtrl', {
              $scope: $scope,
              $timeout: $timeout,
              $location: $location,
              SessionService: SessionService,
              Inventory: Inventory
            });
          });
        });

        it('returns true', function() {
          expect(controller.noDistrict()).toEqual(true);
        });
      });

      describe('when the user has at least one district', function() {
        beforeEach(function() {
          spyOn(SessionService, 'getCurrentUser').and.returnValue({district_ids: [1]});
          inject(function(_$controller_) {
            controller = _$controller_('InventoryModalCtrl', {
              $scope: $scope,
              $timeout: $timeout,
              $location: $location,
              SessionService: SessionService,
              Inventory: Inventory
            });
          });
        });

        it('returns false', function() {
          expect(controller.noDistrict()).toEqual(false);
        });
      });
    });
  });
})();
