describe('Resource: InventoryParticipant', function() {
  var subject, scope, $httpBackend;

  beforeEach(function() {
    module('PDRClient');
    inject(function($resource, $rootScope, InventoryParticipant, $injector) {
      scope = $rootScope.$new();
      subject = InventoryParticipant;
      $httpBackend = $injector.get('$httpBackend');
    });
  });

  it("creates participant with right inventory and user", function(){
    $httpBackend.expectPOST('/v1/inventories/10/participants', {user_id: 40}).respond(201, {});
    var users = subject.create({
      inventory_id: 10
    }, {
      user_id: 40
    });
    $httpBackend.flush();
  });
});
