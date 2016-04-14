(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('inviteUserModal', inviteUserModal);

  function inviteUserModal() {
    return {
      restrict: 'E',
      replace: true,
      transclude: true,
      scope: {
        'sendInvite': '@',
        'role': '@'
      },
      templateUrl: 'client/permissions/invite_user_modal.html',
      controller: 'InviteUserModalCtrl',
      controllerAs: 'inviteUserModal'
    }
  }
})();