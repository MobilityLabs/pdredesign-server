(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InventoryLinksCtrl', InventoryLinksCtrl);

  InventoryLinksCtrl.$inject = [
    '$scope',
    '$modal',
    '$q',
    '$state',
    'EntryItemService',
    'AccessService',
    'SessionService'
  ];

  function InventoryLinksCtrl($scope, $modal, $q, $state, EntryItemService, AccessService, SessionService) {
    var vm = this;
    AccessService.setContext('inventory');

    vm.orderLinks = function(items) {
      return EntryItemService.orderLinks(items);
    };

    // Baggage - defined on scope to preserve behavior with assessmentLinks
    // Will want to refactor into directive

    $scope.requestAccess = function() {
      if (SessionService.isNetworkPartner()) {
        $scope.performAccessRequest('facilitator').then(function() {
        });
      } else {
        $scope.modal = $modal.open({
          templateUrl: 'client/access/request_access.html',
          scope: $scope,
          windowClass: 'request-access-window'
        });
      }
    };

    $scope.close = function() {
      $scope.modal.dismiss('cancel');
    };

    $scope.submitAccessRequest = function(roles) {
      $scope.performAccessRequest(roles).then(function() {
        $scope.modal.dismiss('cancel');
      })
    };

    $scope.performAccessRequest = function(role) {
      var deferred = $q.defer();
      AccessService
          .save($scope.id, role)
          .then(function() {
            $state.go($state.$current, null, {reload: true});
            deferred.resolve();
          }, deferred.reject);
      return deferred.promise;
    };

    vm.invokeAction = function(link) {
      switch (link.type) {
        case 'request_access':
          $scope.requestAccess();
          return;
        default:
          return;
      }
    };

    vm.location = function(link) {
      var inventory_route_stem = '#/inventories/' + $scope.id;
      switch (link.type) {
        case 'finish':
          return inventory_route_stem + '/assign';
        case 'dashboard':
          return inventory_route_stem + '/dashboard';
        case 'inventory':
          return inventory_route_stem + '/edit';
        case 'report':
          return inventory_route_stem + '/report';
        default:
          return '';
      }
    }
  }
})();