PDRClient.config(['$stateProvider', '$urlRouterProvider',
  function($stateProvider, $urlRouterProvider) {

    $stateProvider.state('assessments', {
      url: '/assessments',
      authenticate: true,
      views: {
        '': {
          resolve: {
            assessments: ['Assessment', function(Assessment) { return Assessment.query().$promise;}]
          },
          controller: 'AssessmentsCtrl',
          templateUrl: 'client/views/assessments/index.html'
        },
        'sidebar': {
          controller: 'SidebarCtrl',
          templateUrl: 'client/views/sidebar/sidebar_generic.html'
        }
      }
   })
   .state('assessment_dashboard', {
     url: '/assessments/:id/dashboard',
     authenticate: true,
     params: {
       showModal: false,
     },
     views: {
       '': {
         controller: 'AssessmentDashboardCtrl',
         templateUrl: 'client/views/assessments/dashboard.html'
       },
       'sidebar': {
         controller: 'SidebarCtrl',
         templateUrl: 'client/views/sidebar/assessment_dashboard.html'
       }
     }
   })
   .state('assessment_report', {
     url: '/assessments/:id/report',
     authenticate: true,
     views: {
       '': {
         controller: 'AssessmentReportCtrl',
         templateUrl: 'client/views/assessments/report.html'
       },
       'sidebar': {
         controller: 'SidebarCtrl',
         templateUrl: 'client/views/sidebar/assessment_dashboard.html'
       }
     }
   })
   .state('shared_assessment_report', {
     url: '/assessments/shared/:token/report',
     authenticate: false,
     views: {
       '': {
         controller: 'AssessmentSharedReportCtrl',
         templateUrl: 'client/views/assessments/shared_report.html'
       },
       'sidebar': {
         controller: 'SharedSidebarCtrl',
         templateUrl: 'client/views/sidebar/shared_assessment_dashboard.html'
       }
     }
   })
   .state('assessment_assign', {
     url: '/assessments/:id/assign',
     authenticate: true,
     showFullWidth: true,
     views: {
       'full-width': {
         controller: 'AssessmentAssignCtrl',
         templateUrl: 'client/views/assessments/assign/assign.html'
       }
     }
   })
   .state('assessment_edit', {
     url: '/assessments/:id/edit',
     authenticate: true,
     views: {
       '': {
         controller: 'AssessmentEditCtrl',
         templateUrl: 'client/views/assessments/edit.html'
       },
       'sidebar': {
         controller: 'SidebarCtrl',
         templateUrl: 'client/views/sidebar/sidebar_generic.html'
       }
     }
   });

  }
]);


