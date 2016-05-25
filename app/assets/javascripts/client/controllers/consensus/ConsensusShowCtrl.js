(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ConsensusShowCtrl', ConsensusShowCtrl);

  ConsensusShowCtrl.$inject = [
    '$scope',
    '$rootScope',
    'SessionService',
    'Assessment',
    '$stateParams',
    'ConsensusService',
    'current_context',
    'current_entity',
    'consensus'
  ];

  function ConsensusShowCtrl($scope, $rootScope, SessionService, Assessment, $stateParams, ConsensusService, current_context, current_entity, consensus) {
    $scope.user = SessionService.getCurrentUser();

    $scope.entity = current_entity;
    $scope.consensus = consensus;
    $scope.context = current_context;

    ConsensusService.setContext($scope.context);

    $scope.instructionParagraphs = ConsensusService.instructionParagraphs;

    $scope.exportToPDF = function() {
      $rootScope.$broadcast('building_export_file', {format: 'PDF'});
      ConsensusService
        .exportToPDF()
        .then(function () {
          $rootScope.$broadcast('stop_building_export_file');
        });
    };

    $scope.exportToCSV = function() {
      $rootScope.$broadcast('building_export_file', {format: 'CSV'});
      ConsensusService
        .exportToCSV()
        .then(function () {
          $rootScope.$broadcast('stop_building_export_file');
        });
    };
  }
})();
