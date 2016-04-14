describe('Controller: AssessmentSharedDashboardSidebarCtrl', function() {
  var $scope, $q, $httpBackend, subject;

  var today    = new Date();
  var nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);
  var lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);


  beforeEach(module('PDRClient'));

  beforeEach(inject(function($injector, $controller, $rootScope, $stateParams) {
    $stateParams.token = "token-1234";
    $scope       = $rootScope.$new();
    $httpBackend = $injector.get('$httpBackend');

    subject  = $controller('AssessmentSharedDashboardSidebarCtrl', {
      $scope: $scope
    });

    $httpBackend.when('GET', '/v1/assessments/shared/token-1234').respond({
      id: "token-1234"
    });
    $scope.$digest();
  }));

  it('assessment should be loaded', function() {
    expect($scope.assessment).not.toBe(null);
  });

  it('postMeetingDate should be false for meeting date that is nextWeek', function() {
    $scope.assessment.meeting_date = nextWeek;
    expect($scope.postMeetingDate()).toEqual(false);
  });

  it('preMeetingDate should be true for meeting date that is nextWeek', function() {
    $scope.assessment.meeting_date = nextWeek;
    expect($scope.preMeetingDate()).toEqual(true);
  });

  it('noMeetingDate should be true for meeting date that is null', function() {
    $scope.assessment.meeting_date = null;
    expect($scope.noMeetingDate()).toEqual(true);
  });
});
