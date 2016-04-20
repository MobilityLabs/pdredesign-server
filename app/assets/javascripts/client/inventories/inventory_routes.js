(function() {
  'use strict';
  angular.module('PDRClient')
      .config(InventoryRoutes);

  InventoryRoutes.$inject = [
    '$stateProvider'
  ];

  function InventoryRoutes($stateProvider) {
    $stateProvider.state('inventories', {
          url: '/inventories',
          authenticate: true,
          views: {
            '': {
              resolve: {
                inventory_result: ['Inventory', function(Inventory) {
                  return Inventory.query().$promise;
                }]
              },
              controller: 'InventoryIndexCtrl',
              controllerAs: 'inventoryIndex',
              templateUrl: 'client/inventories/inventory_index.html'
            },
            'sidebar': {
              controller: 'SidebarCtrl',
              templateUrl: 'client/views/sidebar/sidebar_generic.html'
            }
          }
        }).state('inventory_assign', {
          url: '/inventories/:id/assign',
          authenticate: true,
          showFullWidth: true,
          resolve: {
            current_inventory: ['$stateParams', 'Inventory', function($stateParams, Inventory) {
              return Inventory.get({inventory_id: $stateParams.id}).$promise;
            }]
          },
          views: {
            'full-width': {
              controller: 'InventoryAssignCtrl',
              controllerAs: 'inventoryAssign',
              templateUrl: 'client/inventories/assign_inventory.html'
            }
          }
        }).state('inventories_edit', {
          url: '/inventories/:inventory_id/edit',
          authenticate: true,
          views: {
            '': {
              resolve: {
                inventory: ['Inventory', '$stateParams', function(Inventory, $stateParams) {
                  return Inventory.get({inventory_id: $stateParams.inventory_id}).$promise;
                }]
              },
              controller: 'InventoryEditCtrl',
              controllerAs: 'inventoryEdit',
              templateUrl: 'client/inventories/inventory_edit.html'
            },
            'sidebar': {
              controller: 'SidebarCtrl',
              templateUrl: 'client/inventories/edit_sidebar.html'
            }
          }
        }).state('inventories_report', {
          url: '/inventories/:inventory_id/report',
          authenticate: true,
          views: {
            '': {
              resolve: {
                inventory: ['Inventory', '$stateParams', function(Inventory, $stateParams) {
                  return Inventory.get({inventory_id: $stateParams.inventory_id}).$promise;
                }]
              },
              controller: 'InventoryReportCtrl',
              controllerAs: 'inventoryReport',
              templateUrl: 'client/inventories/inventory_report.html'
            },
            'sidebar': {
              resolve: {
                inventory: ['Inventory', '$stateParams', function(Inventory, $stateParams) {
                  return Inventory.get({inventory_id: $stateParams.inventory_id}).$promise;
                }]
              },
              controller: 'InventoryReportSidebarCtrl',
              controllerAs: 'inventoryReportSidebar',
              templateUrl: 'client/inventories/report_sidebar.html'
            }
          }
        });
  }
})();
