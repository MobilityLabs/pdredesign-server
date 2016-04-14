PDRClient.factory('SharedReport', ['$resource', 'UrlService', function($resource, UrlService) {
    return $resource(UrlService.url('assessments/shared/:token/report'));
}]);
