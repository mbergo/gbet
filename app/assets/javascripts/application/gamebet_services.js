var gamebetServices = angular.module('gamebetServices', [
  'ngResource'
]);

gamebetServices.factory('Championship', ['$resource', '$http', '$filter', 'authService',
  function($resource, $http, $filter, authService) {
    var Championship = $resource(Routes.championship_path(':championshipId'));

    Championship.prototype.getLeagues = function() {
      var self = this;
      self.leagues = [];
      self.member_ids = [];
      self.friends = [];

      $http.get(Routes.championship_leagues_path(this.id)).success(function(leagues) {
        self.leagues = leagues;

        angular.forEach(self.leagues, function(league) {
          angular.forEach(league.member_ids, function(member_id) {
            if (self.member_ids.indexOf(member_id) < 0) {
              self.member_ids.push(member_id);
            }
          });
        });

        if (authService.$scope.friends.length > 0) {
          self.updateFriendsList();
        } else {
          authService.$scope.$on('authService:friends', function() {
            self.updateFriendsList();
          });
        }
      });
    };

    Championship.prototype.updateFriendsList = function() {
      var self = this;
      self.friends = $filter('onlyFriends')(self.member_ids);
      angular.forEach(self.leagues, function(league) {
        league.friends = $filter('onlyFriends')(league.member_ids);
      });
    };

    return Championship;
  }
]);

gamebetServices.factory('Round', ['$resource',
  function($resource) {
    return $resource(Routes.championship_round_path(':championshipId', ':roundId'));
  }
]);

gamebetServices.factory('League', ['$resource', '$http', 'authService',
  function($resource, $http, authService) {
    var League = $resource(Routes.championship_league_path(':championshipId', ':leagueId'));

    League.prototype.getRanking = function() {
      var self = this;
      self.ranking = {};

      $http.get(Routes.championship_league_ranking_path(this.championship_id, this.id)).success(function(ranking) {
        self.ranking = ranking;
        angular.forEach(self.ranking.placements, function(placement) {
          authService.$scope.getUserInfo(placement.id.replace('fb_', ''), function(response) {
            authService.$scope.fillUserData(response);
            var placement = $.grep(self.ranking.placements, function(placement) {
              return placement.id === response.gamebetId;
            })[0];

            placement.user = response;
          });
        });
      });
    };

    return League;
  }
]);

gamebetServices.factory('UserLeagues', ['$resource', '$http',
  function($resource, $http) {
    var UserLeagues = $resource(Routes.leagues_user_index_path());

    UserLeagues.leave = function(league, callback) {
      return $http.delete(Routes.delete_league_user_index_path({league_id: league.id})).success(callback);
    };

    UserLeagues.enter = function(league, callback) {
      return $http.post(Routes.add_league_user_index_path({league_id: league.id})).success(callback);
    };

    return UserLeagues;
  }
]);

gamebetServices.factory('Bet', ['$resource', '$http',
  function($resource, $http) {
    var Bet = $resource(Routes.user_round_bets_path(':userId', ':roundId'));

    Bet.setResult = function(roundId, matchId, hostScore, guestScore, callback) {
      return $http.post(Routes.round_bets_path({round_id: roundId}), {match_id: matchId, host_score: hostScore, guest_score: guestScore}).
                    success(callback);
    };

    return Bet;
  }
]);

gamebetServices.factory('Battle', ['$resource', '$http',
  function($resource, $http) {
    var Battle = $resource(Routes.round_battles_path(':roundId'));

    return Battle;
  }
]);
