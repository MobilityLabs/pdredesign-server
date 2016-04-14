(function() {
  'use strict';
  describe('Resource: Inventory', function() {
    var subject,
        $httpBackend,
        $resource;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$httpBackend_, _$resource_, $injector) {
        subject = $injector.get('Inventory');
        $resource = _$resource_;
        $httpBackend = _$httpBackend_;
      });
    });

    describe('#GET', function() {
      it('uses the right URL', function() {
        $httpBackend.expect('GET', '/v1/inventories').respond({inventories: []});
        subject.get();
        $httpBackend.flush();
      })
    });

    describe('#POST', function() {
      it('uses the right URL', function() {
        $httpBackend.expect('POST', '/v1/inventories').respond({200: {}});
        subject.create();
        $httpBackend.flush();
      });
    });

    afterEach(function() {
      $httpBackend.verifyNoOutstandingExpectation();
    })
  });
})();
