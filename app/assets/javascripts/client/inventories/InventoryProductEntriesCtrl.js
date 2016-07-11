(function() {
  'use strict';
  angular.module('PDRClient')
      .controller('InventoryProductEntriesCtrl', InventoryProductEntriesCtrl);

  InventoryProductEntriesCtrl.$inject = [
    '$scope',
    '$q',
    '$compile',
    '$modal',
    'ProductEntry',
    'DTOptionsBuilder',
    'DTColumnBuilder',
    'SessionService'
  ];

  function InventoryProductEntriesCtrl($scope, $q, $compile, $modal, ProductEntry, DTOptionsBuilder, DTColumnBuilder, SessionService) {
    var vm = this;
    vm.inventory = $scope.inventory;
    vm.shared = $scope.shared;
    var inventoryId = vm.shared ? vm.inventory.share_token : vm.inventory.id;

    var options = DTOptionsBuilder.fromFnPromise(function() {
      var deferred = $q.defer();
      ProductEntry.get({inventory_id: inventoryId}).$promise.then(function(results) {
        var productEntries = _.map(results.product_entries, function (productEntry) {
          if (productEntry.deleted_at) {
            productEntry.deleted_at = moment(productEntry.deleted_at).format("MMMM D, YYYY");
          }
          return productEntry;
        });

        vm.deletedProductEntries = _.filter(productEntries, function (productEntry) {
          return typeof productEntry.deleted_at !== "undefined";
        });

        vm.productEntries = _.filter(productEntries, function (productEntry) {
          return typeof productEntry.deleted_at === "undefined";
        });

        deferred.resolve(vm.productEntries);
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

    var PAGE_LENGTH = 20;
    vm.dtOptions = options
      .withPaginationType('full_numbers')
      .withButtons([
        {
          extend: 'columnsToggle',
          columns: '1:visible, 2:visible, 3:visible, 4:visible, 5:visible, 6:visible'
        }
      ])
      .withOption('pageLength', PAGE_LENGTH)
      .withOption('dom', '<"table-header"B>rt<"table-footer"ip>')
      .withOption('drawCallback', function (settings) {
        var $pagination = $('.dataTables_paginate');
        if (vm.productEntries.length > PAGE_LENGTH) {
          $pagination.show();
        } else {
          $pagination.hide();
        }
      });

    vm.dtColumns = [
      DTColumnBuilder.newColumn('general_inventory_question.product_name').withTitle('Name'),
      DTColumnBuilder.newColumn('general_inventory_question.vendor').withTitle('Vendor'),
      DTColumnBuilder.newColumn('general_inventory_question.purpose').withTitle('Used For'),
      DTColumnBuilder.newColumn('technical_question.hosting').withTitle('Hosted'),
      DTColumnBuilder.newColumn('technical_question.connectivity').withTitle('Connected'),
      DTColumnBuilder.newColumn('technical_question.single_sign_on').withTitle('Single Sign-On'),
      DTColumnBuilder.newColumn('usage_question.usage').withTitle('Usage Data')
    ];

    if (!vm.shared) {
      vm.dtColumns.unshift(
        DTColumnBuilder.newColumn(null)
          .withClass('not-sortable')
          .renderWith(actionsHTML)
          .withOption('createdCell', function (cell) {
            $compile(angular.element(cell).contents())($scope);
          })
      );
    }

    $scope.$on('event:dataTableLoaded', function(event, loadedDT) {
      $(".product-entries-table .dataTables_filter")
        .prependTo(".product-entries-table .table-header");

      $(".product-entries-table .dataTables_filter input")
        .keyup(function(event) {
          loadedDT.DataTable
            .search(event.target.value)
            .draw();
        });
    });

    vm.showProductEntryModal = function(productEntryId) {
      $scope.resource = _.find(vm.productEntries, {id: productEntryId});

      vm.modalInstance = $modal.open({
        template: '<product-entry-modal inventory="inventory" resource="resource"></product-entry-modal>',
        scope: $scope
      });
    };

    vm.deleteProductEntry = function (productEntryId) {
      ProductEntry
        .delete({
          inventory_id: vm.inventory.id,
          product_entry_id: productEntryId
        })
        .$promise
        .then(function () {
          vm.dtOptions.reloadData(null, true);
        });
    };

    vm.restoreProductEntry = function (productEntryId) {
      ProductEntry
        .restore({
          inventory_id: vm.inventory.id,
          product_entry_id: productEntryId
        }, {})
        .$promise
        .then(function () {
          vm.dtOptions.reloadData(null, true);
        });
    };

    vm.isOwnerOrFacilitator = function () {
      var currentUser = SessionService.getCurrentUser();

      return currentUser && (currentUser.id === vm.inventory.owner_id || vm.inventory.is_facilitator_or_participant);
    };

    $scope.$on('close-product-entry-modal', function() {
      vm.modalInstance && vm.modalInstance.dismiss('cancel');
      vm.dtOptions.reloadData(null, true);
    });

    function actionsHTML (data) {
      var editHTML = '<i class="fa fa-pencil" ng-click="inventoryProductEntries.showProductEntryModal(' + data.id + ')"></i>&nbsp;&nbsp;';
      var deleteHTML = '<i class="fa fa-remove" ng-click="inventoryProductEntries.deleteProductEntry(' + data.id + ')"></i>';

      return editHTML + deleteHTML;
    }
  }
})();
