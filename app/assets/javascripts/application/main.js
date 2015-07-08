'use strict';

/* App Module */
var gamebetApp = angular.module('gamebetApp', [
  'ngRoute',

  'gamebetLogin',
  'gamebetServices'
]);

gamebetApp.config(['$routeProvider',
  function($routeProvider) {

    var isLoggedIn = ['$q', 'authService', function($q, authService) {
      var deferred = $q.defer();

      var checkLogin = function() {
        if (authService.$scope.isLoggedIn) {
          deferred.resolve();
        } else {
          deferred.reject({ needsAuthentication: true });
        }
      };

      if (authService.$scope.facebookReady) {
        checkLogin();
      } else {
        authService.$scope.$watch("facebookReady", function(ready) {
          if (ready) {
            checkLogin();
          };
        });
      };

      return deferred.promise;
    }];

    $routeProvider.whenAuthenticated = function(path, route) {
      route.resolve = route.resolve || {};

      angular.extend(route.resolve, { isLoggedIn: isLoggedIn });

      return $routeProvider.when(path, route);
    };

    $routeProvider.
      when('/welcome', {
        templateUrl: 'partials/welcome.html',
        controller: 'WelcomeController'
      }).
      whenAuthenticated('/home', {
        templateUrl: 'partials/home.html',
        controller: 'HomeController'
      }).
      whenAuthenticated('/championships/:championshipId', {
        templateUrl: 'partials/championship.html',
        controller: 'ChampionshipsController'
      }).
      whenAuthenticated('/championships/:championshipId/leagues/:leagueId', {
        templateUrl: 'partials/league.html',
        controller: 'LeaguesController'
      }).
      otherwise({
        redirectTo: '/welcome'
      });
  }
]);

gamebetApp.run(['$location', '$rootScope',
  function($location, $rootScope) {
    $rootScope.go = function (path) {
      $location.path(path);
    };

    $rootScope.$on('$routeChangeError', function(ev, current, previous, rejection) {
      if (rejection && rejection.needsAuthentication === true) {
        $rootScope.go('/welcome');
      }
    });
  }
]);
