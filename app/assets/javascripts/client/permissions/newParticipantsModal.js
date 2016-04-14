(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('newParticipantsModal', newParticipantsModal);

  function newParticipantsModal() {
    return {
      restrict: 'E',
      replace: true,
      transclude: true,
      scope: {
        sendInvite: '@'
      },
      templateUrl: 'client/permissions/new_participants_modal.html',
      link: newParticipantsModalLink,
      controller: 'NewParticipantsModalCtrl',
      controllerAs: 'newParticipantsModal'
    }
  }

  function newParticipantsModalLink(scope, element, attributes, controller) {
    controller.updateParticipants();
  }
})();