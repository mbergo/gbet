'use strict';

angular.module('gamebetApp').controller('HomeController', ['$scope', '$http', '$q', 'authService', 'Championship', 'UserLeagues',
  function($scope, $http, $q, authService, Championship, UserLeagues) {
    $scope.championshipsLimit = 3;
    $scope.friendsLimit = 4;

    $scope.championships = Championship.query(function(championships) {
      angular.forEach(championships, function(championship) {
        championship.getLeagues();
      });
    });
  }
]);
