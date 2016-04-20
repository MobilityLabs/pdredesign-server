(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryDataEntriesCtrl', InventoryDataEntriesCtrl);

  InventoryDataEntriesCtrl.$inject = [
    '$scope',
    '$q',
    'DataEntry',
    'DTOptionsBuilder',
    'DTColumnBuilder'
  ];

  function InventoryDataEntriesCtrl($scope, $q, DataEntry, DTOptionsBuilder, DTColumnBuilder) {
    var vm = this;
    vm.inventory = $scope.inventory;
    vm.readOnly = $scope.readOnly;
    var options = DTOptionsBuilder.fromFnPromise(function() {
      var deferred = $q.defer();
      DataEntry.get({inventory_id: vm.inventory.id}).$promise.then(function(results) {
        deferred.resolve(results.data_entries);
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
        columns: '1:visible, 2:visible, 3:visible'
      }
    ]);
    vm.dtColumns = [
      DTColumnBuilder.newColumn('general_data_question.data_type').withTitle('Data Type'),
      DTColumnBuilder.newColumn('general_data_question.data_capture').withTitle('Data Capture'),
      DTColumnBuilder.newColumn('data_entry_question.who_enters_data').withTitle('Who Enters Data'),
      DTColumnBuilder.newColumn('data_access_question.who_access_data').withTitle('Who Access Data'),
    ];

    $scope.$on('close-inventory-data-entry-modal', function() {
      vm.dtOptions.reloadData(null, true);
    });
  }
})();
