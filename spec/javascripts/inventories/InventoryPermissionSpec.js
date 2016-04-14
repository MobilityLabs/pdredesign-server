describe('Resource: InventoryPermission', function() {
  var subject, scope, $httpBackend;

  beforeEach(function() {
    module('PDRClient');
    inject(function($resource, $rootScope, InventoryPermission, $injector) {
      scope = $rootScope.$new();
      subject = InventoryPermission;
      $httpBackend = $injector.get('$httpBackend');
    });
  });

  it("updates permissions with right inventory and roles", function(){
    $httpBackend.expectPATCH('/v1/inventories/10/permissions', {permissions: []}).respond(200, {});
    var users = subject.update({
      inventory_id: 10
    }, {
      permissions: []
    });
    $httpBackend.flush();
  });

  it("list fetches all permissions for inventory", function(){
    $httpBackend.expectGET('/v1/inventories/10/permissions').respond(200, []);
    var users = subject.list({
      inventory_id: 10
    });
    $httpBackend.flush();
  });
});
