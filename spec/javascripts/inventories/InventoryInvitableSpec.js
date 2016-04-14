describe('Resource: InventoryInvitable', function() {
  var subject, scope, $httpBackend;

  beforeEach(function() {
    module('PDRClient');
    inject(function($resource, $rootScope, InventoryInvitable, $injector) {
      scope = $rootScope.$new();
      subject = InventoryInvitable;
      $httpBackend = $injector.get('$httpBackend');
    })
  });

  it("returns all invitables users for an inventory", function(){
    $httpBackend.expectGET('/v1/inventories/10/invitables').respond([1, 2]);
    var users = subject.list({
      inventory_id: 10
    });
    $httpBackend.flush();
    expect(users.length).toEqual(2);
  });
});
