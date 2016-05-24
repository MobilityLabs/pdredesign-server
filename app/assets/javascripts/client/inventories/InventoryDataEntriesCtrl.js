(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryDataEntriesCtrl', InventoryDataEntriesCtrl);

  InventoryDataEntriesCtrl.$inject = [
    '$scope',
    '$q',
    '$compile',
    '$modal',
    'DataEntry',
    'DTOptionsBuilder',
    'DTColumnBuilder'
  ];

  function InventoryDataEntriesCtrl($scope, $q, $compile, $modal, DataEntry, DTOptionsBuilder, DTColumnBuilder) {
    var vm = this;
    vm.inventory = $scope.inventory;
    vm.shared = $scope.shared;

    var inventoryId = vm.shared ? vm.inventory.share_token : vm.inventory.id;
    var options = DTOptionsBuilder.fromFnPromise(function() {
      var deferred = $q.defer();
      DataEntry.get({inventory_id: inventoryId}).$promise.then(function(results) {
        vm.dataEntries = results.data_entries;
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
      DTColumnBuilder.newColumn(null)
          .notSortable()
          .renderWith(actionsHTML)
          .withOption('createdCell', function(cell) {
            $compile(angular.element(cell).contents())($scope);
          }),
      DTColumnBuilder.newColumn('name').withTitle('Name'),
      DTColumnBuilder.newColumn('general_data_question.data_type').withTitle('Data Type'),
      DTColumnBuilder.newColumn('general_data_question.data_capture').withTitle('Data Capture'),
      DTColumnBuilder.newColumn('data_entry_question.who_enters_data').withTitle('Who Enters Data'),
      DTColumnBuilder.newColumn('data_access_question.who_access_data').withTitle('Who Accesses Data')
    ];

    vm.showInventoryDataEntryModal = function(dataEntryId) {
      $scope.resource = _.find(vm.dataEntries, {id: dataEntryId});

      vm.modalInstance = $modal.open({
        template: '<inventory-data-entry-modal inventory="inventory" resource="resource"></inventory-data-entry-modal>',
        scope: $scope
      });
    };

    $scope.$on('close-inventory-data-entry-modal', function() {
      vm.modalInstance && vm.modalInstance.dismiss('cancel');
      vm.dtOptions.reloadData(null, true);
    });

    function actionsHTML(data) {
      return '<i class="fa fa-pencil" ng-click="inventoryDataEntries.showInventoryDataEntryModal(' + data.id + ')"></i>';
    }
  }
})();
