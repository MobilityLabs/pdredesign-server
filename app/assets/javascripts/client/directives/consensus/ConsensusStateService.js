(function() {
  'use strict';

  angular.module('PDRClient')
      .service('ConsensusStateService', ConsensusStateService);

  function ConsensusStateService() {
    var consensusData = {};

    var addConsensusData = function(data) {
      consensusData.scores = data.scores;
      consensusData.categories = data.categories;
      consensusData.data = data.categories;
      consensusData.teamRoles = data.teamRoles;
      consensusData.isReadOnly = data.is_completed || false;
      consensusData.participantCount = data.participant_count;
    };

    var getConsensusData = function() {
      return consensusData;
    };

    return {
      addConsensusData: addConsensusData,
      getConsensusData: getConsensusData
    };
  }
})();