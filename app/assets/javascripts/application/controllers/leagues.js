'use strict';

angular.module('gamebetApp').controller('LeaguesController', ['$scope', '$rootScope', '$q', '$routeParams', 'authService', 'Championship', 'League', 'Round', 'Bet', 'Battle', 'UserLeagues',
  function($scope, $rootScope, $q, $routeParams, authService, Championship, League, Round, Bet, Battle, UserLeagues) {
    $scope.currentRound = {};
    $scope.currentRoundBets = {};
    $scope.closes_at = null;
    $scope.oponnent = null;

    $scope.league = League.get({championshipId: $routeParams.championshipId, leagueId: $routeParams.leagueId}, function() {
      $scope.league.getRanking();
    });

    var processUserBets = function() {
      angular.forEach($scope.currentRound.matches, function(match) {
        match.bet = "0x0";
        angular.forEach($scope.currentRoundBets, function(bet) {
          if (match.id === bet.match) {
            match.bet = bet.host_score + "x" + bet.guest_score;
          }
        });
      });
    };

    var updateCurrentRound = function(roundId) {
      $scope.currentRound = Round.get({championshipId: $scope.championship.id, roundId: roundId});
      $scope.currentRoundBets = Bet.query({userId: authService.$scope.user.gamebetId, roundId: roundId});
      $q.all([$scope.currentRound.$promise, $scope.currentRoundBets.$promise]).then(processUserBets);
      Battle.get({roundId: roundId}, function(roundBattles) {
        var battle = roundBattles[$routeParams.leagueId];

        if (battle) {
          var oponnentID = ((battle.host_id == authService.$scope.user.gamebetId) ? battle.guest_id : battle.host_id).replace('fb_', '');
          authService.$scope.getUserInfo(oponnentID, function(response) {
            $scope.$apply(function() {
              $scope.oponnent = response;
              authService.$scope.fillUserData($scope.oponnent);
            });
          });
        }
      });
    };

    $scope.championship = Championship.get({championshipId: $routeParams.championshipId}, function(championship) {
      updateCurrentRound(championship.current_round);
      var round = $.grep(championship.rounds, function(round) {
        return round.id === championship.current_round;
      })[0];

      $scope.closes_at = new Date(round.closes_at);
    });

    $scope.save = function(match, host_score, guest_score) {
      Bet.setResult($scope.currentRound.id, match.id, host_score, guest_score, function() {});
    };

    $scope.changeRound = function(order) {
      var newRound = $.grep($scope.championship.rounds, function(round) {
        return round.order === order;
      })[0];

      if (newRound) {
        updateCurrentRound(newRound.id);
      }
    };

    $scope.leaveLeague = function(championship, league) {
      UserLeagues.leave(league, function() {
        $rootScope.go('/championships/' + $routeParams.championshipId);
      });
    };
  }
]);
