(function() {
  'use strict';

  angular.module('PDRClient')
      .config(ConsensusRouteConfig);


  ConsensusRouteConfig.$inject = [
    '$stateProvider'
  ];

  function ConsensusRouteConfig($stateProvider) {
    $stateProvider
        .state('consensus_show', {
          url: '/assessments/:assessment_id/consensus/:response_id',
          authenticate: true,
          resolve: {
            consensus: ['Consensus', '$stateParams', function(Consensus, $stateParams) {
              return Consensus.get({
                assessment_id: $stateParams.assessment_id,
                id: $stateParams.response_id,
                team_role: null
              }).$promise;
            }]
          },
          views: {
            '': {
              controller: 'ConsensusShowCtrl',
              templateUrl: 'client/views/consensus/show.html'
            },
            'sidebar': {
              controller: 'SidebarResponseCardCtrl',
              templateUrl: 'client/views/sidebar/response_card.html'
            }
          }
        })
        .state('consensus_create', {
          url: '/assessments/:assessment_id/consensus',
          authenticate: true,
          views: {
            '': {
              controller: 'ConsensusCreateCtrl',
              templateUrl: 'client/views/consensus/show.html'
            },
            'sidebar': {
              controller: 'SidebarResponseCardCtrl',
              templateUrl: 'client/views/sidebar/sidebar_generic.html'
            }
          }
        });
  }
})();
