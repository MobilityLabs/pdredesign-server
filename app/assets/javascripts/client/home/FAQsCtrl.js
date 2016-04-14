PDRClient.controller('FAQsCtrl', [
  '$scope',
  '$timeout',
  '$location',
    function($scope, $timeout, $location) {
      $scope.extractQueryParams = function() {
        var search = $location.search();
        $scope.topic   = search["topic"];
        $scope.role    = search["role"];

      };

      $scope.extractQueryParams();
    }
]);


