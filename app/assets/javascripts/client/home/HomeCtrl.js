(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('HomeCtrl', HomeCtrl);

  HomeCtrl.$inject = [
    '$scope',
    'Tool',
    'SessionService',
    '$timeout',
    '$state'
  ];

  function HomeCtrl($scope, Tool, SessionService, $timeout, $state) {
    $scope.user = SessionService.getCurrentUser();
    $scope.tools = [];

    $scope.isNetworkPartner = function() {
      return SessionService.isNetworkPartner();
    };

    $scope.setToolTip = function() {
      $timeout(function() {
        $('ul.tool').find('li')
            .popover({
              placement: 'right',
              html: true,
              trigger: 'manual'
            }).on('show.bs.popover', function() {
          $('ul.tool').find('li').not(this).popover('hide');
        }).mouseenter(function(e) {
          $(this).popover('show');
        }).on('click', function() {
          $('ul.tool').find('li').popover('hide');
        });
      });
    };

    $scope.updateTools = function() {
      if (SessionService.getUserAuthenticated() == false)
        return;
      Tool.query().$promise.then(function(data) {
        $scope.tools = data;
        $scope.setToolTip();
      });
    };

    $scope.updateTools();

    $scope.emptyTool = function() {
      return '<p class="no-link">This item is currently under development. Please stay tuned.</p>';
    };

    $scope.popoverContent = function(tool) {
      if (!tool.description)
        return $scope.emptyTool();

      var output = "<div><div class='row'><div class='col-md-12'><p class='greeting'>" +
          tool.title + "</p>" + '<p class="description">' + tool.description + '</p>' + '<p>';
      if (!tool.url)
        output += $scope.emptyTool();
      else
        output += "<div class='col-md-3 pull-right'><a href='" + tool.url + "' class='btn btn-primary'>Go</a></div></div>" + "</div>";

      output += "</p>" + "</div></div>";
      return output;
    };

    $scope.$watch($scope.tools, function() {
      $scope.setToolTip();
    });

    $scope.$watch('user', function() {
      if ($state.is('root') && ($scope.user && $scope.user.id))
        $state.go('home');
    });

    $scope.$on('updated_tools', function() {
      $scope.updateTools();
    });
  }
})();
