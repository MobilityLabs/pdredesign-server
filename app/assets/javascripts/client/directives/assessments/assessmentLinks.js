PDRClient.directive('assessmentLinks', [
    function() {
      return {
        restrict: 'E',
        replace: false,
        scope: {},
        templateUrl: 'client/views/directives/assessment_index_links.html',
        link: function(scope, elm, attrs) {
          scope.active = attrs.active;
          scope.title  = attrs.title;
          scope.type   = attrs.type;
          scope.role   = attrs.role;
          scope.id     = attrs.id;
          scope.consensusId = attrs.consensusId;
        },
        controller: [
          '$scope',
          '$modal',
          '$rootScope',
          '$location',
          '$timeout',
          '$state',
          '$q',
          'AccessRequest',
          'SessionService',
          function($scope, $modal, $rootScope, $location, $timeout, $state, $q, AccessRequest, SessionService) {
            $scope.isNetworkPartner = SessionService.isNetworkPartner;

            $scope.linkIcon = function(type){
              icons = {
                  "response": "check",
                  "request_access": "unlock-alt",
                  "pending": "spinner",
                  "dashboard": "dashboard",
                  "consensus": "group",
                  "new_consensus": "group",
                  "edit_report": "group",
                  "show_report": "group",
                  "show_response": "group",
                  "none": "group",
                  "finish": "pencil",
                  "messages": "envelope",
                  "report": "file-text-o",
              };
              return icons[type];
            };

            $scope.districtMemberPopoverContent = "<div> <i class='fa fa-bullhorn'></i><span>Facilitator</span><p>Facilitators share responsibility with the district facilitator to contact participants and view their individual responses, facilitate the consensus meeting, and view the final consensus report.</p>" +
                                                  "<i class='fa fa-edit'></i><span>Participant</span><p>Participants respond to the individual readiness assessment survey and take part in the consensus meeting. They can view the final consensus report.</p>";

            $scope.networkPartnerPopoverContent = "<i class='fa fa-bullhorn'></i><span>Organizer</span><p>Organizers share responsibility with the district facilitator to contact participants and view their individual responses, facilitate the consensus meeting, and view the final consensus report.</p>" +
                                                  "<i class='fa fa-eye'></i><span>Observer</span><p>Observers have read-only access to the final consensus report. They cannot view individual participant responses or data.</p> </div>";

            $scope.createConsensusModal = function() {
              $scope.modal = $modal.open({
                templateUrl: 'client/views/modals/create_consensus.html',
                scope: $scope
              });
            };

            $scope.popoverContent = function() {
              if($scope.isNetworkPartner())
                return $scope.networkPartnerPopoverContent;

              return $scope.districtMemberPopoverContent;
            };

            $scope.addRequestPopover = function() {
              $timeout(function(){
                $("[data-toggle=requestPopover]").popover({
                  html : true,
                  placement: 'top',
                  trigger: 'hover',
                });
              });
            };

            $scope.requestAccess = function() {
              if($scope.isNetworkPartner()) {
                $scope.performAccessRequest('facilitator').then(function() {});
              } else {
                $scope.modal = $modal.open({
                  templateUrl: 'client/views/modals/request_access.html',
                  scope: $scope,
                  windowClass: 'request-access-window',
                  opened: $scope.addRequestPopover()
                });
              }
            };

            $scope.close = function() {
              $scope.modal.dismiss('cancel');
            };

            $scope.redirectToCreateConsensus = function() {
              $scope.close();
              $location.url($scope.assessmentLink('new_consensus', true));
            };

            $scope.submitAccessRequest = function(roles) {
              $scope.performAccessRequest(roles).then(function() {
                $scope.modal.dismiss('cancel');
              })
            };

            $scope.performAccessRequest = function(role) {
              var deferred = $q.defer();
              AccessRequest
              .save({assessment_id: $scope.id}, {roles: [role]})
              .$promise
              .then(function() {
                $state.go($state.$current, null, { reload: true });
                deferred.resolve();
              }, deferred.reject);
              return deferred.promise;
            };

            $scope.gotoLocation   = function(location) {
              if(!location) return;

              if(location.match(/\/assessments\/.*\/consensus$/))
                $scope.createConsensusModal();
              else if(location == 'request_access')
                $scope.requestAccess();
              else
                $location.url(location);
            };

            $scope.assessmentLink = function(type, active) {
              if(typeof type === 'undefined')
                return false;

              routes = {
                "request_access": "request_access",
                "new_consensus": "/assessments/" + $scope.id + "/consensus",
                "dashboard":     "/assessments/" + $scope.id + "/dashboard",
                "consensus":     "/assessments/" + $scope.id + "/consensus",
                "finish":        "/assessments/" + $scope.id + "/assign",
                "report":        "/assessments/" + $scope.id + "/report",
                "response":      "/assessments/" + $scope.id + "/responses",
                "edit_report":   "/assessments/" + $scope.id + "/consensus/" + $scope.consensusId,
                "show_report":   "/assessments/" + $scope.id + "/consensus/" + $scope.consensusId,
                "messages":      "/assessments/" + $scope.id + "/dashboard",
                "consensus":     "/assessments/" + $scope.id + "/consensus/" + $scope.consensusId,
                "show_response": "/assessments/" + $scope.id + "/consensus/" + $scope.consensusId,
              };

              return routes[type];
            };

        }],

      };
    }
]);
