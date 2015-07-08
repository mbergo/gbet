var gamebetLogin = angular.module('gamebetLogin', ['facebook']);

gamebetLogin.config(['FacebookProvider',
  function(FacebookProvider) {
    FacebookProvider.setLocale('pt_BR');
    FacebookProvider.setAppId('1436853629883247');
    FacebookProvider.init();
  }
]);

gamebetLogin.factory('authService', ['$rootScope', '$q', '$timeout', 'Facebook', '$filter',
  function($rootScope, $q, $timeout, Facebook, $filter) {
    $scope = $rootScope.$new();
    $scope.facebookReady = false;
    $scope.isLoggedIn = false;
    $scope.user = {};
    $scope.friends = [];

    $scope.getUserInfo = function(userID, callback) {
      Facebook.api('/' + userID + '?fields=name,id', function(response) {
        callback(response);
      });
    };

    var fillUserData = function(user) {
      user.gamebetId = 'fb_' + user.id;
      user.picture = "https://graph.facebook.com/" + user.id + "/picture";
    };
    $scope.fillUserData = fillUserData;

    var timeout = $timeout(function() {
      $scope.facebookReady = true;
    }, 10000);

    $scope.$on('Facebook:authResponseChange', function(ev, response) {
      $timeout.cancel(timeout);
      $scope.facebookReady = true;

      if (response.status == 'connected') {
        $scope.isLoggedIn = true;
        $scope.user = { id: response.authResponse.userID };
        fillUserData($scope.user);
        $scope.$broadcast("authService:login");
      }
    });

    $scope.$on('Facebook:login', function(ev, response) {
      if (!$scope.isLoggedIn) {
        return;
      }

      Facebook.api('/me?fields=name', function(response) {
        $scope.$apply(function() {
          $scope.user = response;
          fillUserData($scope.user);
        });
      });

      Facebook.api('/me/friends?fields=name,installed', function(response) {
        $scope.$apply(function() {
          $scope.friends = $filter('filter')(response.data, {installed: true});

          angular.forEach($scope.friends, function(friend) {
            fillUserData(friend);
          });

          $scope.$broadcast("authService:friends");
        });
      });
    });

    return { $scope: $scope };
  }
]);

gamebetLogin.controller('AuthenticationController', ['$scope', 'Facebook', 'authService',
  function($scope, Facebook, authService) {
    $scope.facebookLogin = function() {
      if (!authService.$scope.isLoggedIn) {
        Facebook.login();
      } else {
        authService.$scope.$broadcast("authService:login");
      }
    };
    $scope.authScope = authService.$scope;
  }
]);

gamebetLogin.filter('onlyFriends', ['authService',
  function(authService) {
    return function(input) {
      return $.grep(authService.$scope.friends, function(friend) {
        return input.indexOf(friend.gamebetId) >= 0;
      });
    };
  }
]);
