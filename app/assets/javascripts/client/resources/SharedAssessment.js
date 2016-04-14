PDRClient.factory('SharedAssessment', ['$resource', 'UrlService', function($resource, UrlService) {
    return $resource(UrlService.url('assessments/shared/:token'), null);
}]);
