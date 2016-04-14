(function() {
  'use strict';

  angular.module('PDRClient')
      .directive('toolDetails', toolDetails);

  function toolDetails() {
    return {
      restrict: 'E',
      transclude: true,
      replace: true,
      scope: {
        model: '='
      },
      link: entityDetailsLink,
      templateUrl: 'client/common_create/tool_details.html',
      controller: 'ToolDetailsCtrl',
      controllerAs: 'toolDetails'
    }
  }

  function entityDetailsLink(scope, element) {
    scope.datetime = angular.element(element).find('.datetime').datetimepicker({
      pickTime: false
    });

    scope.datetime.on('dp.change', function() {
      angular.element(element).find('#due-date').trigger('change');
    });
  }
})();
