(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('addNewParticipants', addNewParticipants);

  function addNewParticipants() {
    return {
      restrict: 'E',
      transclude: true,
      replace: true,
      scope: {
        sendInvite: '@'
      },
      templateUrl: 'client/permissions/add_new_participants.html',
      controller: 'AddNewParticipantsCtrl',
      controllerAs: 'addNewParticipants'
    }
  }
})();