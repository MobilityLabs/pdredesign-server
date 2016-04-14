PDRClient.directive('signup', [
    function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          isNetworkPartner: '@',
          isAdministrator: '@',
        },
        templateUrl: 'client/views/directives/signup.html',
        controller: [
          '$scope',
          '$rootScope',
          '$location',
          '$state',
          'User',
          'SessionService',
          function($scope, $rootScope, $location, $state, User, SessionService) {

            $scope.user = {};

            $scope.login = function(user) {
              SessionService
              .authenticate(user.email, user.password)
              .then(function(user) {
                $location.path('/');
                $rootScope.$broadcast('session_updated');
              });
            };

            $scope.setRole = function(user) {
              if($scope.isNetworkPartner)
                return user["role"] = "network_partner";
            };

            $scope.createUser = function(user) {
              $scope.setRole(user);

              $scope.success = null;
              $scope.errors  = null;

              User
                .create(user)
                .$promise
                .then(function(data) {
                    $scope.success = "User created";
                    $scope.login(user);
                  }, function(response) {
                    if(response.data && response.data.base) {
                      sessionStorage.setItem('invitation_message', response.data.base);
                      $state.go('invite', {token: response.data.invitation_token});
                      return;
                    }
                    $scope.errors  = response.data.errors;
                  }
                );
            };

          }],
      };
    }
]);
