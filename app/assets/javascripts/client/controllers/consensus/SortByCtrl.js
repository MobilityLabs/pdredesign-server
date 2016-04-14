(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('SortByCtrl', SortByCtrl);

  SortByCtrl.$inject = [
    '$scope'
  ];

  function SortByCtrl($scope) {
    var vm = this;

    vm.changeViewMode = function(mode) {
      var correctedMode = mode.toLowerCase();
      if (correctedMode === 'variance') {
        vm.categories = vm.sortByVariance(vm.data);
      } else if (correctedMode === 'category') {
        vm.categories = vm.sortByCategory();
      }
    };

    vm.sortByCategory = function() {
      return vm.data;
    };

    vm.sortByVariance = function(categories) {
      var tmpObject = {};
      var keys = [];

      var sorted = {};

      angular.forEach(categories, function(category, _key) {
        angular.forEach(category.questions, function(question, key) {
          if (typeof tmpObject[question.variance] === 'undefined') {
            tmpObject[question.variance] = {
              name: question.variance,
              questions: []
            };
          }
          keys.push(question.variance);
          tmpObject[question.variance]['questions'].push(question);
        });
      });

      keys.sort().reverse();

      angular.forEach(keys, function(key) {
        sorted[key] = tmpObject[key];
      });

      return sorted;
    };

    $scope.$watch('data', function(val) {
      vm.data = val;
    }).bind(vm);

    $scope.$watch('categories', function(val) {
      vm.categories = val;
    }).bind(vm);
  }
})();