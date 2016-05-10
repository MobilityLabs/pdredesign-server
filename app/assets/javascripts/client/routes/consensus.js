PDRClient.config(['$stateProvider', '$urlRouterProvider',
  function($stateProvider, $urlRouterProvider) {

    $stateProvider.state('consensus_show', {
      url: '/assessments/:assessment_id/consensus/:response_id',
      authenticate: true,
      resolve: {
        current_context: function () { return 'assessment'; },
        current_entity: ['$stateParams', 'Assessment', function($stateParams, Assessment) {
          return Assessment.get({id: $stateParams.assessment_id}).$promise;
        }],
        consensus: ['Consensus', '$stateParams', function(Consensus, $stateParams) { return Consensus
          .get({assessment_id: $stateParams.assessment_id,
                id: $stateParams.response_id,
                team_role: null})
          .$promise;}]
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
     resolve: {
       current_context: function () { return "assessment"; }
     },
     views: {
       '': {
         controller: 'ConsensusCreateCtrl'
       }
     }
   });
  }
]);

