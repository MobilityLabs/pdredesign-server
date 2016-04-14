(function() {
  'use strict';
  angular.module('PDRClient')
      .directive('createParticipants', createParticipants);

  function createParticipants() {
    return {
      restrict: 'E',
      replace: true,
      transclude: true,
      scope: {
        model: '='
      },
      templateUrl: 'client/common_create/participants.html',
      controller: 'CreateParticipantsCtrl',
      controllerAs: 'createParticipants'
    }
  }
})();