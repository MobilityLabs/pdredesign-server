(function() {
  'use strict';
  describe('Controller: AddInventoryUsersLink', function() {
    var $scope, subject, $q, InventoryInvitable;

    beforeEach(function() {
      module('PDRClient');
      inject(function($injector, $controller, $rootScope) {
        $scope = $rootScope.$new(true);
        InventoryInvitable = $injector.get('InventoryInvitable');
        spyOn(InventoryInvitable, 'list').and.callFake(function(query, params) {
          var deferred = $q.defer();
          deferred.resolve([{}, {}]);
          return { $promise: deferred.promise };
        });
        $q = $injector.get('$q');

        $scope.inventoryId = 4

        subject = $controller('AddInventoryUsersLinkCtrl', {
          $scope: $scope
        });
      });
    });

    describe('#loadInvitables', function() {
      beforeEach(function() {
        subject.loadInvitables();
      });

      it('loads invitables user for the inventory', function() {
        expect(InventoryInvitable.list).toHaveBeenCalledWith({ inventory_id: 4});
      });

      it('sets invitables', function() {
        expect(subject.invitables.$promise).not.toBe(null);
      });
    });

    describe('#invitablesFound', function() {
      it('false when invitables are null', function() {
        subject.invitables = null;
        expect(subject.invitablesFound()).toBeFalsy();
      });

      it('false when invitables are empty', function() {
        subject.invitables = [];
        expect(subject.invitablesFound()).toBe(false);
      });

      it('true when invitables are not empty', function() {
        subject.invitables = [{}];
        expect(subject.invitablesFound()).toBe(true);
      });
    });
  });
})();
