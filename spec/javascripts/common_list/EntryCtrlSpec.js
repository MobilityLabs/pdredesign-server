(function() {
  'use strict';

  describe('Controller:  EntryCtrl', function() {
    var controller,
        $location,
        $scope,
        SessionService;

    beforeEach(function() {
      module('PDRClient');
      inject(function(_$controller_, _$rootScope_, _$location_, $injector) {
        $location = _$location_;
        $scope = _$rootScope_.$new(true);
        SessionService = $injector.get('SessionService');

        controller = _$controller_('EntryCtrl', {
          $scope: $scope,
          $location: $location,
          SessionService: SessionService
        });
      });
    });

    describe('#orderLinks', function() {
      describe('with links in order of dashboard, report, and consensus', function() {
        var links = {
          consensus: {
            title: 'Consensus'
          },
          report: {
            title: 'Report'
          },
          dashboard: {
            title: 'View Dashboard'
          }
        };

        var result = null;

        beforeEach(function() {
          result = controller.orderLinks(links);
        });

        it('sets the dashboard as the first entry', function() {
          expect(result[0].title).toEqual('View Dashboard');
        });

        it('sets the consensus as the middle entry', function() {
          expect(result[1].title).toEqual('Consensus');
        });

        it('sets the report as the last entry', function() {
          expect(result[2].title).toEqual('Report');
        });
      });

      describe('with links in order of report, finish and consensus', function() {
        var links = {
          report: {
            title: 'Report',
            active: false,
            type: 'report'
          },
          finish: {
            title: 'Finish & Assign',
            active: true,
            type: 'finish'
          },
          consensus: {
            title: 'Consensus',
            active: true,
            type: 'new_consensus'
          }
        };

        var result = null;

        beforeEach(function() {
          result = controller.orderLinks(links);
        });

        it('sets the first entry as Finish & Assign', function() {
          expect(result[0].title).toEqual('Finish & Assign');
        });

        it('sets the middle entry as Report', function() {
          expect(result[1].title).toEqual('Report');
        });

        it('sets the last entry as Consensus', function() {
          expect(result[2].title).toEqual('Consensus');
        });
      });
    });

    describe('#roundNumber', function() {

      it('rounds down to the nearest integer', function() {
        expect(controller.roundNumber(50.999)).toEqual(50);
      });
    });

    describe('#meetingTime', function() {
      var result;
      describe('when the passed time is null', function() {
        beforeEach(function() {
          result = controller.meetingTime(null);
        });

        it('displays TBD', function() {
          expect(result).toEqual('TBD');
        });
      });

      describe('when the passed time is a date in an ISO 8601 format', function() {
        beforeEach(function() {
          result = controller.meetingTime('2016-03-18T00:00:00Z');
        });

        it('displays the time in Do MMM YYYY format (local timezone)', function() {
          expect(result).toEqual('18th Mar 2016');
        });
      });
    });

    describe('#consensusReportIcon', function() {
      var result;
      describe('when there is no consensus', function() {
        var entity = {};
        beforeEach(function() {
          result = controller.consensusReportIcon(entity);
        });

        it('returns fa-spinner', function() {
          expect(result).toEqual('fa-spinner');
        });
      });
      describe('when the consensus has not been completed', function() {
        var entity = {
          consensus: {
            is_completed: false
          }
        };
        beforeEach(function() {
          result = controller.consensusReportIcon(entity);
        });

        it('returns fa-spinner', function() {
          expect(result).toEqual('fa-spinner');
        });
      });
      describe('when the consensus has been completed', function() {
        var entity = {
          consensus: {
            is_completed: true
          }
        };
        beforeEach(function() {
          result = controller.consensusReportIcon(entity);
        });

        it('returns fa-check', function() {
          expect(result).toEqual('fa-check');
        });
      });
    });
  });
})();
