(function() {
  'use strict';
  angular.module('PDRClient')
      .config(HomeRoutes);

  HomeRoutes.$inject = [
    '$stateProvider',
    '$urlRouterProvider'
  ];

  function HomeRoutes($stateProvider, $urlRouterProvider) {
    $stateProvider.state('home', {
      url: '/home',
      authenticate: true,
      views: {
        '': {
          controller: 'HomeCtrl',
          templateUrl: 'client/home/home_user.html'
        },
        'sidebar': {
          controller: 'SidebarCtrl',
          templateUrl: 'client/views/sidebar/sidebar_generic.html'
        }
      }
    });

    $stateProvider.state('faqs', {
      url: '/faqs?role&topic',
      showFullWidth: true,
      views: {
        'full-width': {
          controller: 'FAQsCtrl',
          templateUrl: 'client/home/home_faqs.html'
        }
      }
    });

    $stateProvider.state('root', {
      url: '/',
      showFluid: true,
      views: {
        'full-width': {
          controller: 'HomeCtrl',
          templateUrl: 'client/home/home_anon.html'
        }
      }
    });

    $urlRouterProvider.otherwise('/');
  }
})();