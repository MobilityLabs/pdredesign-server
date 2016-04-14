(function() {
  'use strict';
  describe('Controller: ManageInventoryPermissions', function() {
    var $scope, $q, subject, InventoryPermission;

    beforeEach(function() {
      module('PDRClient');
      inject(function($injector, $controller, $rootScope) {
        $scope = $rootScope.$new(true);
        InventoryPermission = $injector.get('InventoryPermission');
        $q = $injector.get('$q');

        $scope.inventoryId = 4

        spyOn(InventoryPermission, 'list').and.callFake(function(query, params) {
          var deferred = $q.defer();
          deferred.resolve([{}, {}]);
          return { $promise: deferred.promise };
        });

        spyOn(InventoryPermission, 'update').and.callFake(function(query, params) {
          var deferred = $q.defer();
          deferred.resolve([{}, {}]);
          return { $promise: deferred.promise };
        });

        subject = $controller('ManageInventoryPermissionsCtrl', {
          $scope: $scope
        });
      })
    });

    describe('#loadList', function() {
      beforeEach(function() {
        subject.loadList();
      });

      it('loads permissions for inventory', function() {
        expect(InventoryPermission.list).toHaveBeenCalledWith({ inventory_id: 4});
      });

      it('sets list', function() {
        expect(subject.list.$promise).not.toBe(null);
      });
    });

    describe('#savePermissions', function() {
      beforeEach(function() {
        subject.savePermissions([
          {
            email: 'hi@example.com',
            role: 'facilitator'
          },
          {
            email: 'pete@example.com',
            role: 'participant'
          }
        ]);
      });

      it('saves permissions', function() {
        expect(InventoryPermission.update).toHaveBeenCalledWith({ inventory_id: 4}, { permissions:[
          {
            email: 'hi@example.com',
            role: 'facilitator'
          },
          {
            email: 'pete@example.com',
            role: 'participant'
          }
        ]}, jasmine.any(Function));
      });
    });
  });
})();
