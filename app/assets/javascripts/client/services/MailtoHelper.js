PDRClient.factory('MailtoHelper', [function() {
  var service = {};

  service.compose = function(options) {
    var body = escape(options.body);
    var subject = escape(options.subject);
    var link = "mailto:?subject=" + subject + "&body=" + body;
    return link;
  };
  return service;
}]);

