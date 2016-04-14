PDRClient = angular.module("PDRClient", [
  'ngResource',
  'ngRoute',
  'ngSanitize',
  'templates',
  'angular-redactor',
  'angularMoment',
  'angularFileUpload',
  'ng.shims.placeholder',
  'ui.utils',
  'ui.router',
  'ui.bootstrap',
  'xeditable'
]);

angular.module("PDRClient").run(function ($rootScope, $state, $stateParams) {
    $rootScope.$state       = $state;
    $rootScope.$stateParams = $stateParams;
});

angular.module("PDRClient").run([
  '$rootScope',
  '$state',
  '$stateParams',
  '$anchorScroll',
  function ($rootScope, $state, $stateParams, $anchorScroll) {
    $rootScope.$on('$stateChangeStart', function() {
      $rootScope.$broadcast('start_change');
    });
    $rootScope.$on('$stateChangeSuccess', function() {
      $rootScope.$broadcast('success_change');
      $anchorScroll();
    });
}]);

angular.module("PDRClient").run(
  ['$rootScope', '$state', '$location', 'SessionService',
  function ($rootScope, $state, $location, SessionService) {
    $rootScope.$on("$stateChangeStart", function(event, toState, toParams, fromState, fromParams){
      $rootScope.showFullWidth = toState.showFullWidth;
      $rootScope.showFluid     = toState.showFluid;
    });
  }]);

angular.module("PDRClient").run(
  ['$rootScope', '$state', '$location', 'SessionService',
  function ($rootScope, $state, $location, SessionService) {
    $rootScope.$on("$stateChangeStart", function(event, toState, toParams, fromState, fromParams){
      if (toState.authenticate && !SessionService.getUserAuthenticated()){
        $rootScope.$broadcast('success_change');
        $state.go("login", {redirect: $location.url()});
        event.preventDefault();
      }
    });
  }]);

angular.module("PDRClient").config(['$tooltipProvider', function($tooltipProvider){
  $tooltipProvider.setTriggers({
    'mouseenter': 'blur',
    'click': 'click',
    'focus': 'blur',
  });
}]);

angular.module('PDRClient').run(function(editableOptions, editableThemes) {
  editableOptions.theme = 'bs3';
  editableThemes.bs3.submitTpl = '<button type="submit" class="btn btn-primary"><i class="fa fa-floppy-o"></i></button>';
  editableThemes.bs3.cancelTpl = '<button type="button" class="btn btn-default" ng-click="$form.$cancel()"><i class="fa fa-ban"></i></button>'
});
