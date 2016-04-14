(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('inviteMessage', inviteMessage);

  function inviteMessage() {
    return {
      restrict: 'E',
      replace: true,
      transclude: true,
      scope: {
        model: '=',
        district: '='
      },
      templateUrl: 'client/common_create/invite.html',
      controller: 'InviteMessageCtrl',
      controllerAs: 'inviteMessage'
    }
  }
})();