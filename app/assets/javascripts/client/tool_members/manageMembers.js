(function () {
  'use strict';

  angular.module('PDRClient')
    .directive('manageMembers', manageMembers);

  function manageMembers() {
    return {
      restrict: 'E',
      scope: {
        'context': '@'
      },
      templateUrl: 'client/tool_members/manage_members.html'
    }
  }
})();