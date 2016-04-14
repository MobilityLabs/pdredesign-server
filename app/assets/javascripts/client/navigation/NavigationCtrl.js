(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('NavigationCtrl', NavigationCtrl);

  NavigationCtrl.$inject = [
    '$scope',
    'SessionService',
    '$location'
  ];

  function NavigationCtrl($scope, SessionService, $location) {
    $scope.updateTemplate = function() {
      SessionService.setUserTemplate(
          $scope,
          'client/navigation/navigation_user.html',
          'client/navigation/navigation_anon.html'
      );
    };
    $scope.updateTemplate();
    $scope.user = SessionService.getCurrentUser();

    $scope.currentLocation = '';
    $scope.activeClassFor = function(location) {
      if ($scope.currentLocation === location) {
        return 'active';
      }
      return '';
    };

    $scope.$watch(function() {
      return $location.url();
    }, function(url) {
      switch (url) {
        case '/assessments':
          return $scope.currentLocation = "current_state";
        case '':
          return $scope.currentLocation = "home";
        case '/':
          return $scope.currentLocation = "home";
        case '/login':
          return $scope.currentLocation = "login";
        case '/administrators':
          return $scope.currentLocation = "administrators";
        case '/educators':
          return $scope.currentLocation = "educators";
          return $scope.currentLocation = "networks";
        case '/inventories':
          return $scope.currentLocation = 'inventories';
        default:
          return '';
      }
    });

    $scope.$on('session_updated', function() {
      SessionService.syncUser();
      $scope.user = SessionService.getCurrentUser();
      $scope.updateTemplate();
    });
  }
})();
