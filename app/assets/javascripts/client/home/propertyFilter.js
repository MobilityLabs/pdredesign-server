(function() {
  'use strict';
  angular.module('PDRClient')
      .filter('propertyFilter', propertyFilter);

  function propertyFilter() {
    return function(items, property, value) {
      var filtered = [];
      angular.forEach(items, function(item) {
        if (!value || item[property] === value) {
          filtered.push(item);
        }
      });
      return filtered;
    };
  }
})();