(function() {
  'use strict';

  angular.module('PDRClient')
      .controller('ResponseAnswerCtrl', ResponseAnswerCtrl);

  ResponseAnswerCtrl.$inject = [
      'ResponseHelper'
  ];

  function ResponseAnswerCtrl(ResponseHelper) {
    var vm = this;

    vm.extractAnswerTitle = function(answer) {
      return ResponseHelper.answerTitle(answer);
    };
  }
})();