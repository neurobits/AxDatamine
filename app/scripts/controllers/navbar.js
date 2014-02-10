'use strict';

angular.module('axDatamineApp')
  .controller('NavbarCtrl', function ($scope, $location, Auth) {
    $scope.menu = [
	{
      'title': 'Home',
      'link': '/'
    }, 
	{
      'title': 'Reportes',
      'link': '/reports'
    }, 
	{
      'title': 'Settings',
      'link': '/settings'
    }];
    
    $scope.logout = function() {
      Auth.logout()
      .then(function() {
        $location.path('/login');
      });
    };
    
    $scope.isActive = function(route) {
      return route === $location.path();
    };
  });
