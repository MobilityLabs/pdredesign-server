PDRClient.factory('AssessmentService', ['$state', 'MailtoHelper', function($state, MailtoHelper) {
  var service = {};

  service.sharedUrl = function(token) {
    return $state.href('shared_assessment_report', {token: token}, {absolute: true});
  };

  service.shareMailto = function(assessment) {
    var url = service.sharedUrl(assessment.share_token);
    var options = {
      subject: "Assessment Report: " + assessment.name,
      body: "Hi,\nI would like to share an assessment report for " + assessment.name + "\nPlease click in the link below to access the report:\n" + url  + ".\n"
    };
    return MailtoHelper.compose(options);
  };
  return service;
}]);

