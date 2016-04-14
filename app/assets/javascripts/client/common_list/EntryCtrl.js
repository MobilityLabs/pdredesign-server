(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('EntryCtrl', EntryCtrl);

  EntryCtrl.$inject = [
    '$location',
    'SessionService'
  ];

  function EntryCtrl($location, SessionService) {
    var vm = this;

    vm.consensusReportIcon = function(entity) {
      if (entity.consensus && entity.consensus.is_completed) {
        return 'fa-check';
      } else {
        return 'fa-spinner';
      }
    };

    vm.draftStatusIcon = function(entity) {
      if (entity.has_access) {
        return 'fa-eye';
      } else {
        return 'fa-minus-circle';
      }
    };

    vm.roundNumber = function(number) {
      return Math.floor(number);
    };

    vm.isNetworkPartner = function() {
      return SessionService.isNetworkPartner();
    };

    vm.meetingTime = function(date) {
      if (date != null) {
        return moment(date, 'YYYY-MM-DDTHH:mm:ss').format('Do MMM YYYY');
      } else {
        return 'TBD';
      }
    };

    vm.gotoLocation = function(location) {
      if (location) {
        $location.url(location);
      }
    };


    vm.activeAssessmentLink = function(entity) {
      if (vm.responseLink(entity)) {
        return 'active';
      } else {
        return '';
      }
    };

    vm.responseLink = function(entity) {
      switch (entity.response_link) {
        case 'new_response':
          return '/assessments/' + entity.id + '/responses';
        case 'response':
          return '/assessments/' + entity.id + '/responses/' + entity.responses[0].id;
        case 'consensus':
          return '/assessments/' + entity.id + '/consensus/' + entity.consensus.id;
        case 'none':
          return false;
      }
    };

    vm.orderLinks = function(items) {
      var filteredArray = [];
      angular.forEach(items, function(item) {
        var title = item.title.toLowerCase();
        switch (true) {
          case title === 'complete survey':
            item.order = 0;
          case title === 'view dashboard':
            item.order = 1;
            break;
          case title === 'view consensus':
            item.order = 2;
            break;
          case title === 'finish & assign':
            item.order = 3;
            break;
          default:
            item.order = 4;
            break;
        }
        filteredArray.push(item);
      });

      /* Sorts links so Dashboard is first
       and Report is last.
       */

      filteredArray.sort(function(a, b) {
        switch (true) {
          case a.order < b.order:
            return -1;
          case a.order == b.order:
            return 0;
          case a.order > b.order:
          default:
            return 1;
        }
      });
      return filteredArray;
    };
  }
})();
