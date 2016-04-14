(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('inventoryModal', inventoryModal);

  function inventoryModal() {
    return {
      restrict: 'E',
      transclude: true,
      replace: true,
      scope: {},
      link: inventoryModalLink,
      templateUrl: 'client/home/inventory_modal.html',
      controller: 'InventoryModalCtrl',
      controllerAs: 'inventoryModal'
    }
  }

  function inventoryModalLink(scope, element) {
    scope.datetime = angular.element(element[0].querySelector('.datetime')).datetimepicker({
      pickTime: false
    });

    scope.datetime.on('dp.change', function() {
      angular.element(element[0].querySelector('#deadline')).trigger('change');
    });
  }
})();