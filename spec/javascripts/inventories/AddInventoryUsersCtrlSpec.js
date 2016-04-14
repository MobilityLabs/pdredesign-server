(function() {
  'use strict';
  describe('Controller: AddInventoryUsers', function() {
    var $scope, $location, $q, $httpBackend, subject, InventoryParticipant;

    beforeEach(function() {
      module('PDRClient');
      inject(function($injector, $controller, $rootScope) {
        $scope = $rootScope.$new(true);
        $httpBackend = $injector.get('$httpBackend');
        InventoryParticipant = $injector.get('InventoryParticipant');
        $q = $injector.get('$q');

        $scope.inventoryId = 4

        subject = $controller('AddInventoryUsersCtrl', {
          $scope: $scope
        });

        $httpBackend.when('GET', '/v1/inventories/4/invitables').respond([]);
      })
    });

    it('retrieve initial invitables', function() {
      $httpBackend.expectGET('/v1/inventories/4/invitables').respond([]);
      $httpBackend.flush();
    });

    describe('#addUser', function() {
      beforeEach(function() {
        spyOn(subject, 'loadInvitables').and.callThrough();
        spyOn(InventoryParticipant, 'create').and.callFake(function(query, params) {
          var deferred = $q.defer();
          deferred.resolve();
          return { $promise: deferred.promise };
        });
        subject.addUser({
          id: 50
        });
        $scope.$root.$digest();
      })

      it('creates participant', function() {
        expect(InventoryParticipant.create).toHaveBeenCalledWith({ inventory_id: 4}, { user_id: 50 });
      });

      it('reloads participants', function() {
        expect(subject.loadInvitables).toHaveBeenCalled();
      });
    });
  });
})();
