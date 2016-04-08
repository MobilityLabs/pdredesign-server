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
    var options = DTOptionsBuilder.fromFnPromise(function() {
      var deferred = $q.defer();
      ProductEntry.get({inventory_id: $scope.inventoryId}).$promise.then(function(results) {
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
      'columnsToggle'
    ]);
    vm.dtColumns = [
      DTColumnBuilder.newColumn('id').withTitle('ID'),
      DTColumnBuilder.newColumn('general_inventory_question.product_name').withTitle('Name'),
    ];
  }
})();
