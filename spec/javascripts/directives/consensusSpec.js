describe('Directive: consensus', function() {
  var $scope,
      $timeout,
      $location,
      $rootScope,
      $httpBackend,
      isolatedScope,
      element;

  var score1    = {id: 1, evidence: "hello", value: 1, editMode: null};
  var question1 = {id: 1, score: score1 };
  var answer1   = {id: 1, value: 2};

  beforeEach(module('PDRClient'));

  beforeEach(inject(function($injector) {
    var $compile = $injector.get('$compile');
    $rootScope   = $injector.get('$rootScope');
    $timeout     = $injector.get('$timeout');
    $location    = $injector.get('$location');
    $httpBackend = $injector.get('$httpBackend');
    $scope       = $rootScope.$new();

    element    = angular.element('<consensus data-assessment-id=1 data-response-id=1>'
                               + '</consensus>');

    $compile(element)($scope);
    $scope.$digest();

    isolatedScope = element.isolateScope();
  }));

  describe('#scoreFilter', function(){
    var $filter, scores;

    beforeEach(inject(function($injector) {
      $filter = $injector.get('$filter');
    }));

    it('filters the right scores', function() {
      scores = [{question_id: 1}, {question_id:1}, {question_id:2}];
      expect($filter('scoreFilter')(scores, 1).length).toEqual(2);
      expect($filter('scoreFilter')(scores, 2).length).toEqual(1);
    });
  });

  it('isConsensus will be true by default ', function() {
    expect(isolatedScope.isConsensus).toEqual(true);
  });

  describe('#assignAnswerToQuestion', function() {
    beforeEach(inject(function($injector) {
      isolatedScope.isReadOnly = false;
    }));

    it('will return false if $scope.isReadOnly is true', function() {
      isolatedScope.isReadOnly = true;
      expect(isolatedScope.assignAnswerToQuestion(answer1, question1)).toEqual(false);
    });

    it('isAlert should be true if score evidence is missing', function() {
      var score2 = {id: 1, evidence: "", value: 1, editMode: null};
      var question2 = {id: 1, score: score2 };
      isolatedScope.assignAnswerToQuestion(answer1, question2)
      expect(question2.isAlert).toEqual(true);
    });

    it('does not error on an undefined score', function(){
      var score2 = {id: 1, evidence: "", value: 1, editMode: null};
      var question2 = {id: 1};
      isolatedScope.assignAnswerToQuestion(answer1, question2)
    })

  });

  describe('#updateConsensus', function() {
    beforeEach(inject(function($injector) {
      $httpBackend.when('GET', '/v1/assessments/1/consensus/1')
        .respond({
          scores: [score1],
          categories: [1,2,3],
          team_roles: ['some', 'role'],
          is_completed: true,
          participant_count: 5
        });

    }));

    it('gets data on callback and sets scores, data,' +
       ' categories, isReadOnly, and participantCount', function() {
      isolatedScope.updateConsensus();
      $httpBackend.flush();

      expect(isolatedScope.scores).toEqual([score1]);
      expect(isolatedScope.categories).toEqual([1,2,3]);
      expect(isolatedScope.isReadOnly).toEqual(true);
      expect(isolatedScope.teamRoles).toEqual(['some', 'role']);
      expect(isolatedScope.participantCount).toEqual(5);
    });

    it('sends the teamRole when its set', function() {
      $httpBackend.expectGET('/v1/assessments/1/consensus/1?team_role=some_role')
        .respond({});

      isolatedScope.teamRole = 'some_role';
      isolatedScope.updateConsensus();
      $httpBackend.flush();
    });

  });

  describe('#updateTeamRole', function(){
    it('updates the $scope.teamRole var', function(){
      isolatedScope.teamRole = null;
      isolatedScope.updateTeamRole("some_role");
      expect(isolatedScope.teamRole).toEqual('some_role');
    });

    it('updates the $scope.teamRole var to null when empty', function(){
      isolatedScope.teamRole = "some role";
      isolatedScope.updateTeamRole("");
      expect(isolatedScope.teamRole).toEqual(null);
    });

    it('triggers a consensus update', function(){
      spyOn(isolatedScope, 'updateConsensus').and.callThrough();
      isolatedScope.updateTeamRole("some_role");
      expect(isolatedScope.updateConsensus).toHaveBeenCalled();
    });
  });

  describe('#submit_consensus', function() {

    it('calls function redirectToReport()', function(){
      spyOn(isolatedScope, 'redirectToReport');
      $httpBackend.expectPUT("/v1/assessments/1/consensus/1").respond({});
      $rootScope.$broadcast("submit_consensus");

      $httpBackend.flush();
      expect(isolatedScope.redirectToReport).toHaveBeenCalledWith('1');
    });

    it('redirects to assessment correct report', function() {
      isolatedScope.redirectToReport(1);
      expect($location.path()).toEqual('/assessments/1/report')
    });

  });

});
