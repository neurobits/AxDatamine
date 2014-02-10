'use strict';

angular.module('axDatamineApp')
  .factory('Session', function ($resource) {
    return $resource('/api/session/');
  });
