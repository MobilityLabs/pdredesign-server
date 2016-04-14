(function() {
  'use strict';

  describe('Controller: ToolDetails', function() {
    var $scope,
        $controller,
        subject,
        SessionService,
        CreateService;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$rootScope_, $injector) {
        $scope = _$rootScope_.$new(true);
        $controller = _$controller_;
        SessionService = $injector.get('SessionService');
        CreateService = $injector.get('CreateService');
      });
    });

    describe('on initialization', function() {
      beforeEach(function() {
        spyOn(CreateService, 'loadScope');
        subject = $controller('ToolDetailsCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      });

      it('sends the scope to the CreateService', function() {
        expect(CreateService.loadScope).toHaveBeenCalledWith($scope);
      });
    });

    describe('#defaultDate', function() {
      beforeEach(function() {
        subject = $controller('ToolDetailsCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      });

      describe('when model is undefined', function() {
        var model = undefined;
        it('returns undefined', function() {
          expect(subject.defaultDate(model)).toBeUndefined();
        });
      });

      describe('when model contains a valid due_date', function() {
        var model = {due_date: '2012-12-21T00:00:00'};
        it('returns the date in MM/DD/YYYY format', function() {
          expect(subject.defaultDate(model)).toBe('12/21/2012');
        });
      });

      describe('when model contains a valid deadline', function() {
        var model = {deadline: '2012-12-21T00:00:00'};
        it('returns the date in MM/DD/YYYY format', function() {
          expect(subject.defaultDate(model)).toBe('12/21/2012');
        });
      });
    });

    describe('#determineDistrict', function() {
      describe('when no districts match', function() {
        var model = {district_id: 4};
        beforeEach(function() {
          spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 30}, {id: 27}, {id: 31}]});
          subject = $controller('ToolDetailsCtrl', {
            $scope: $scope,
            SessionService: SessionService,
            CreateService: CreateService
          });
        });
        it('uses the first district available to the user', function() {
          subject.determineDistrict(model);
          expect(subject.district).toEqual({id: 30});
        });
      });

      describe('when a district matches', function() {
        var model = {district_id: 3};
        beforeEach(function() {
          spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 1}, {id: 2}, {id: 3}]});
          subject = $controller('ToolDetailsCtrl', {
            $scope: $scope,
            SessionService: SessionService,
            CreateService: CreateService
          });
        });

        it('uses the district ID supplied', function() {
          subject.determineDistrict(model);
          expect(subject.district).toEqual({id: 3});
        });
      });

      describe('when no districts exist on the user', function() {
        var model = {district_id: 1};
        beforeEach(function() {
          spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: []});
          subject = $controller('ToolDetailsCtrl', {
            $scope: $scope,
            SessionService: SessionService,
            CreateService: CreateService
          });
        });

        it('leaves the district undefined', function() {
          subject.determineDistrict(model);
          expect(subject.district).toBeUndefined();
        });
      });
    });

    describe('#save', function() {
      var entity = {text: 'Entity'};
      beforeEach(function() {
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 1}, {id: 2}, {id: 3}]});
        spyOn(CreateService, 'loadDistrict');
        spyOn(CreateService, 'saveAssessment');

        subject = $controller('ToolDetailsCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      });

      it('delegates to CreateService#loadDistrict with the defined (default) district', function() {
        subject.save(entity);
        expect(CreateService.loadDistrict).toHaveBeenCalledWith({id: 1});
      });

      it('delegates to CreateService$saveAssessment with the correct entity', function() {
        subject.save(entity);
        expect(CreateService.saveAssessment).toHaveBeenCalledWith(entity);
      });
    });

    describe('#formattedDate', function() {
      var date = '2012-11-20T00:00:00';
      beforeEach(function() {
        spyOn(CreateService, 'formattedDate');
        subject = $controller('ToolDetailsCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      });

      it('delegates to CreateService#formattedDate', function() {
        subject.formattedDate(date);
        expect(CreateService.formattedDate).toHaveBeenCalledWith(date);
      });
    });

    describe('$on: toggle-saving-state', function() {
      var $rootScope;
      beforeEach(function() {
        inject(function(_$rootScope_) {
          $rootScope = _$rootScope_;
        });
        subject = $controller('ToolDetailsCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
      });

      it('toggles the state of saving', function() {
        expect(subject.saving).toBe(false);
        $rootScope.$broadcast('toggle-saving-state');
        expect(subject.saving).toBe(true);
      });
    });

    describe('$watch: model', function() {
      beforeEach(function() {
        spyOn(SessionService, 'getCurrentUser').and.returnValue({districts: [{id: 47}, {id: 2}, {id: 3}]});
        subject = $controller('ToolDetailsCtrl', {
          $scope: $scope,
          SessionService: SessionService,
          CreateService: CreateService
        });
        $scope.$apply('model={due_date: "2014-07-12T00:00:00", district_id: 47}');
      });

      it('sets the district', function() {
        expect(subject.district).toEqual({id: 47});
      });

      it('sets and formats the date', function() {
        expect(subject.date).toBe('07/12/2014');
      });
    });
  });
})();