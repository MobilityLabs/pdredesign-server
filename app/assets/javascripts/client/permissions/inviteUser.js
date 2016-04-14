(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('inviteUser', inviteUser);

  function inviteUser() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: 'client/permissions/invite_user.html',
      scope: {
        'sendInvite': '@',
        'role': '@'
      },
      controller: 'InviteUserCtrl',
      controllerAs: 'inviteUser'
    };
  }
})();
