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
    'DTColumnBuilder',
    'SessionService'
  ];

  function InventoryDataEntriesCtrl($scope, $q, $compile, $modal, DataEntry, DTOptionsBuilder, DTColumnBuilder, SessionService) {
    var vm = this;
    vm.inventory = $scope.inventory;
    vm.shared = $scope.shared;

    var inventoryId = vm.shared ? vm.inventory.share_token : vm.inventory.id;
    var options = DTOptionsBuilder.fromFnPromise(function() {
      var deferred = $q.defer();
      DataEntry.get({inventory_id: inventoryId}).$promise.then(function(results) {
        var dataEntries = _.map(results.data_entries, function (dataEntry) {
          if (dataEntry.deleted_at) {
            dataEntry.deleted_at = moment(dataEntry.deleted_at).format("MMMM D, YYYY");
          }
          return dataEntry;
        });

        vm.deletedDataEntries = _.filter(dataEntries, function (dataEntry) {
          return typeof dataEntry.deleted_at !== "undefined";
        });

        vm.dataEntries = _.filter(dataEntries, function (dataEntry) {
          return typeof dataEntry.deleted_at === "undefined";
        });

        deferred.resolve(vm.dataEntries);
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

    vm.deleteDataEntry = function (dataEntryId) {
      DataEntry
        .delete({
          inventory_id: vm.inventory.id,
          data_entry_id: dataEntryId
        })
        .$promise
        .then(function () {
          vm.dtOptions.reloadData(null, true);
        });
    };

    vm.restoreDataEntry = function (dataEntryId) {
      DataEntry
        .restore({
          inventory_id: vm.inventory.id,
          data_entry_id: dataEntryId
        }, {})
        .$promise
        .then(function () {
          vm.dtOptions.reloadData(null, true);
        });
    };

    vm.isOwnerOrFacilitator = function () {
      return SessionService.getCurrentUser().id === vm.inventory.owner_id
             || vm.inventory.is_facilitator;
    }

    $scope.$on('close-inventory-data-entry-modal', function() {
      vm.modalInstance && vm.modalInstance.dismiss('cancel');
      vm.dtOptions.reloadData(null, true);
    });

    function actionsHTML (data) {
      var editHTML = '<i class="fa fa-pencil" ng-click="inventoryDataEntries.showInventoryDataEntryModal(' + data.id + ')"></i>&nbsp;&nbsp;';
      var deleteHTML = '<i class="fa fa-remove" ng-click="inventoryDataEntries.deleteDataEntry(' + data.id + ')"></i>';

      return editHTML + deleteHTML;
    }
  }
})();
