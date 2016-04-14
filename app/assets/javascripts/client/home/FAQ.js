PDRClient.factory('FAQ', ['$resource','UrlService',
  function($resource, UrlService) {
    return $resource(UrlService.url('faqs'));
  }
]);
