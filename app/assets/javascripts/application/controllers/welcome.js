'use strict';

angular.module('gamebetApp').controller('WelcomeController', ['$rootScope', 'authService',
  function($rootScope, authService) {
    authService.$scope.$on('authService:login', function() {
      $rootScope.go('/home');
    });
  }
]);