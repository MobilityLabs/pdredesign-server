(function() {
  'use strict';
  angular.module('PDRClient')
      .service('CreateService', CreateService);

  CreateService.$inject = [
    '$window',
    '$location',
    'Assessment'
  ];

  function CreateService($window, $location, Assessment) {
    var service = this;

    this.loadDistrict = function(district) {
      this.district = district;
    };

    this.formattedDate = function(date) {
      return moment(date).format('ll');
    };

    this.loadScope = function(scope) {
      this.scope = scope;
    };

    this.toggleSavingState = function() {
      this.scope.$emit('toggle-saving-state');
    };

    this.alertError = false;

    this.emitSuccess = function(message) {
      this.scope.$emit('add_assessment_alert', {type: 'success', msg: message});
    };

    this.emitError = function(message) {
      this.scope.$emit('add_assessment_alert', {type: 'danger', msg: message});
    };

    this.assignAndSaveAssessment = function(assessment) {
      if (assessment.message === null || assessment.message === '') {
        this.alertError = true;
        return;
      }

      if ($window.confirm('Are you sure you want to send out the assessment and invite all your participants?')) {
        this.alertError = false;
        this
            .saveAssessment(assessment, true)
            .then(function() {
              $location.path('/assessments');
            });
      }
    };

    this.saveAssessment = function(assessment, assign) {
      if (assessment.name === '') {
        this.emitError('Assessment needs a name!');
        return;
      }

      assessment.district_id = this.district.id;

      service.toggleSavingState();
      assessment.due_date = moment($("#due-date").val(), 'MM/DD/YYYY').toISOString();

      if (assign) {
        assessment.assign = true;
      }

      return Assessment
          .save({id: assessment.id}, assessment)
          .$promise
          .then(function() {
            service.toggleSavingState();
            service.emitSuccess('Assessment Saved!');
          }, function() {
            service.toggleSavingState();
            service.emitError('Could not save assessment');
          });
    };
  }
})();
