PDRClient.factory('SharedPriority', ['$resource', 'UrlService', function($resource, UrlService) {
    return $resource(UrlService.url('assessments/shared/:token/priorities'));
}]);
