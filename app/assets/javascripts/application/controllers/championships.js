'use strict';

gamebetApp.controller('ChampionshipsController', ['$scope', '$rootScope', '$routeParams', 'Championship', 'UserLeagues',
  function($scope, $rootScope, $routeParams, Championship, UserLeagues) {
    $scope.friendsLimit = 4;

    $scope.userLeagues = UserLeagues.query({}, function(userLeagues) {
      angular.forEach(userLeagues, function(userLeague) {
        if (userLeague.championship_id == $routeParams.championshipId) {
          $rootScope.go('/championships/' + $routeParams.championshipId + '/leagues/' + userLeague.id);
        }
      });

      $scope.championship = Championship.get({championshipId: $routeParams.championshipId}, function(championship) {
        championship.getLeagues();
      });
    });

    $scope.enterLeague = function(league) {
      UserLeagues.enter(league, function() {
        $rootScope.go('/championships/' + $routeParams.championshipId + '/leagues/' + league.id);
      });
    };
  }
]);