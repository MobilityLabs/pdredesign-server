PDRClient.directive('districtSelect', ['UrlService', '$timeout',
  function(UrlService, $timeout) {
    return {
      restrict: 'E',
      replace: false,
      scope: {
        preselected: '=',
        districts:   '=',
        required:    '@'
      },
      templateUrl: 'client/views/directives/district_select.html',
      link: function(scope, elm, attrs) {
        scope.multiple = attrs.multiple == "true" ? true : false;
        scope.prepopulated = false;

        scope.createSelectizeElement = function() {
          var selectize = $(elm).find('#districts').selectize({
            valueField:  'id',
            labelField:  'text',
            searchField: 'text',
            maxItems:    attrs.multiple == "true" ? Infinity : 1,
            create:      false,
            render: {
              option: function(item, escape) {
                return '<div>' + item.text + '</div>';
              }
            },
            load: function(query, callback) {
              if (!query.length) return callback();
              $.ajax({
                url: UrlService.url('districts/search') + '?query=' + encodeURIComponent(query),
                type: 'GET',
                error: function() {
                  callback();
                },
                success: function(res) {
                  callback(res.results);
                }
              });
            }
          });

          return selectize;
        };

        scope.prepopulateDistricts = function(districts) {
          var ids = [];

          angular.forEach(districts, function(district, key) {
            scope.selectize.addOption({id: district.id, text: district.text});
            ids.push(district.id);
          });

          /* without a timeout angular will trigger a digest cycle
             because html has been changed.
          */
          $timeout(function() {
            scope.selectize.setValue(ids);
            scope.triggerDigest();
          });
          scope.prepopulated = true;
        };

        scope.triggerDigest = function() {
          if(!scope.$$phase) scope.$apply();
        };

        $timeout(function() {
          scope.selectize = scope.createSelectizeElement()[0].selectize;
          scope.$watch('preselected', function(districts) {
            if(!districts || scope.prepopulated) return;
            scope.prepopulateDistricts(districts);
          });
        });
      },
    };
  }
]);
