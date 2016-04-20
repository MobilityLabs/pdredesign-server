(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryProductEntriesCtrl', InventoryProductEntriesCtrl);

  InventoryProductEntriesCtrl.$inject = [
    '$scope',
    '$q',
    'ProductEntry',
    'DTOptionsBuilder',
    'DTColumnBuilder'
  ];

  function InventoryProductEntriesCtrl($scope, $q, ProductEntry, DTOptionsBuilder, DTColumnBuilder) {
    var vm = this;
    vm.inventory = $scope.inventory;
    vm.readOnly = $scope.readOnly;
    var options = DTOptionsBuilder.fromFnPromise(function() {
      var deferred = $q.defer();
      ProductEntry.get({inventory_id: vm.inventory.id}).$promise.then(function(results) {
        deferred.resolve(results.product_entries);
      }, deferred.reject);
      return deferred.promise;
    });

    //HACK: activate datatables.buttons plugin, we'll be able to get rid of this once we migrate to angular-datatables 0.3.x
    options.withButtons = function(buttonsOptions) {
      var options = this;
      var buttonsPrefix = 'B';
      options.dom = options.dom ? options.dom : $.fn.dataTable.defaults.sDom;
      if (options.dom.indexOf(buttonsPrefix) === -1) {
        options.dom = buttonsPrefix + options.dom;
      }
      options.buttons = buttonsOptions;
      return options;
    };
    
    vm.dtOptions = options.withPaginationType('full_numbers').withButtons([
      {
        extend: 'columnsToggle',
        columns: '1:visible, 2:visible, 3:visible, 4:visible, 5:visible, 6:visible'
      }
    ]);
    vm.dtColumns = [
      DTColumnBuilder.newColumn('general_inventory_question.product_name').withTitle('Name'),
      DTColumnBuilder.newColumn('general_inventory_question.vendor').withTitle('Vendor'),
      DTColumnBuilder.newColumn('general_inventory_question.purpose').withTitle('Used for'),
      DTColumnBuilder.newColumn('technical_question.hosting').withTitle('Hosted'),
      DTColumnBuilder.newColumn('technical_question.connectivity').withTitle('Connected'),
      DTColumnBuilder.newColumn('technical_question.single_sign_on').withTitle('Single sign on?'),
      DTColumnBuilder.newColumn('usage_question.usage').withTitle('Usage data?')
    ];

    $scope.$on('close-product-entry-modal', function() {
      vm.dtOptions.reloadData(null, true);
    });
  }
})();
