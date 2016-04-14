(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('manageParticipantsModal', manageParticipantsModal);

  function manageParticipantsModal() {
    return {
      restrict: 'E',
      scope: {},
      transclude: true,
      replace: true,
      templateUrl: 'client/permissions/manage_participants_modal.html',
      controller: 'ManageParticipantsModalCtrl',
      controllerAs: 'manageParticipantsModal',
      link: manageParticipantsModalLink
    }
  }

  function manageParticipantsModalLink(scope, element, attributes, controller) {
    controller.updateData();
  }
})();
