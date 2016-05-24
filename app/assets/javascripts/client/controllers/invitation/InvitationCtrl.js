(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('InvitationCtrl', InvitationCtrl);

  InvitationCtrl.$inject = [
    '$scope',
    '$stateParams',
    '$rootScope',
    'Invitation',
    'SessionService'
  ];

  function InvitationCtrl($scope, $stateParams, $rootScope, Invitation, SessionService) {
    $scope.token = $stateParams.token;
    $scope.invitedUser = Invitation.get({token: $scope.token});
    $scope.inviteObject = {};
    $scope.isError = null;
    $scope.errors = null;
    $scope.showalert = false;
    $scope.alerts = [];

    var invitation_message = sessionStorage.getItem('invitation_message');
    if (invitation_message) {
      $scope.alerts.push({type: 'info', msg: invitation_message});
      sessionStorage.removeItem('invitation_message');
    }

    $scope.showError = function(msg) {
      $scope.alerts.push({type: 'danger', msg: msg});
    };

    $scope.closeAlert = function(index) {
      $scope.alerts.splice(index, 1);
    };

    $scope.populateErrors = function(errors) {
      angular.forEach(errors, function(error, key) {
        angular.forEach(error, function(e) {
          var message = key + ": " + e;
          $scope.showError(message);
        });
      });
    };

    $scope.redeemInvite = function() {
      $scope.inviteObject = {
        first_name: $scope.invitedUser.first_name,
        last_name: $scope.invitedUser.last_name,
        team_role: $scope.invitedUser.team_role,
        password: $scope.invitedUser.password,
        email: $scope.invitedUser.email
      };
      Invitation
          .save({token: $scope.token}, $scope.inviteObject)
          .$promise
          .then(function() {
            SessionService
                .authenticate($scope.inviteObject.email, $scope.inviteObject.password)
                .then(function() {
                  $rootScope.$broadcast('session_updated');
                  var redirectUrl = null;
                  if ($scope.invitedUser.inventory_id) {
                    redirectUrl = '/inventories/' + $scope.invitedUser.inventory_id + '/report';
                  } else {
                    redirectUrl = '/assessments/' + $scope.invitedUser.assessment_id + '/responses';
                  }
                  SessionService.syncAndRedirect(redirectUrl);
                });
          }, function(response) {
            $scope.populateErrors(response.data.errors)
          });
    };
  }
})();
