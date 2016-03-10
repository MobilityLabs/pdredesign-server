PDRClient.directive('sharedAssessmentPriority', [
    function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          token: '@',
        },
        templateUrl: 'client/views/directives/shared_assessment_priority.html',
        controller: [
          '$scope',
          '$attrs',
          'SharedPriority',
          function($scope, $attrs, SharedPriority) {
            $scope.scoredAverage = function(category) {
              return Math.ceil(category.average);
            };

            $scope.roundedAverage = function(score) {
              return parseFloat(score).toFixed(2);
            };

            $scope.updateCategories = function() {
              $scope.loading = true;
              SharedPriority
                .query({token: $attrs.token})
                .$promise
                .then(function(categories) {
                  $scope.categories = categories;
                  $scope.loading = false;
                });
            };

            $attrs.$observe('token', function(token) {
              if(token) $scope.updateCategories(token);
            });
        }],
      };
    }
]);
