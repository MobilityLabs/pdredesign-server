(function() {
  'use strict';

  describe('Controller: InviteMessage', function() {
    var subject,
        $scope,
        SessionService,
        CreateService;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$rootScope_, _$injector_) {
        $scope = _$rootScope_.$new(true);
        SessionService = _$injector_.get('SessionService');
        CreateService = _$injector_.get('CreateService');

        subject = _$controller_('InviteMessageCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      });

      spyOn(SessionService, 'getCurrentUser');
    });

    describe('$on: toggle-save-state', function() {
      var $rootScope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });
      });

      it('toggles the initial state of false to true', function() {
        subject.saving = false;
        $rootScope.$broadcast('toggle-saving-state');
        expect(subject.saving).toEqual(true);
      });


      it('toggles the the set state of true to false', function() {
        subject.saving = true;
        $rootScope.$broadcast('toggle-saving-state');
        expect(subject.saving).toEqual(false);
      });
    });

    describe('#save', function() {
      beforeEach(inject(function(_$controller_) {
        subject = _$controller_('InviteMessageCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      }));

      it('delegates to CreateService#saveAssessment', function() {
        spyOn(CreateService, 'saveAssessment');
        subject.save({}, true);
        expect(CreateService.saveAssessment).toHaveBeenCalled();
      });
    });

    describe('#assignAndSave', function() {
      beforeEach(inject(function(_$controller_) {
        subject = _$controller_('InviteMessageCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      }));

      it('delegates to CreateService#assignAndSaveAssesssment', function() {
        spyOn(CreateService, 'assignAndSaveAssessment');
        subject.assignAndSave({});
        expect(CreateService.assignAndSaveAssessment).toHaveBeenCalled();
      });
    });

    describe('#formattedDate', function() {
      it('delegates to CreateService', function() {
        spyOn(CreateService, 'formattedDate');
        subject.formattedDate(new Date('01/01/2001'));
        expect(CreateService.formattedDate).toHaveBeenCalled();
      });
    });

    describe('$watch: district', function() {
      beforeEach(inject(function(_$controller_) {
        spyOn(CreateService, 'loadDistrict');
        subject = _$controller_('InviteMessageCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      }));

      it('passes the district to the service', function() {
        $scope.$apply('district={"id": 1}');
        expect(CreateService.loadDistrict).toHaveBeenCalledWith({id: 1});
      });
    });

    describe('on initialization', function() {
      beforeEach(inject(function(_$controller_) {
        spyOn(CreateService, 'loadDistrict');
        spyOn(CreateService, 'loadScope');
        subject = _$controller_('InviteMessageCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      }));

      it('invokes loadScope with the bound scope', function() {
        expect(CreateService.loadScope).toHaveBeenCalledWith($scope);
      });
    });
  });
})();
