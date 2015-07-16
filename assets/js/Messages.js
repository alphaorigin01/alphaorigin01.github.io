// Generated by CoffeeScript 1.9.2
(function() {
  'use strict';
  var app;

  app = angular.module('Messages', ['AthleteService', 'PubNubService']);


  /*                      Controllers */

  app.controller('MessagesController', [
    '$scope', '$rootScope', '$timeout', 'Athlete', 'PubNub', function($scope, $rootScope, $timeout, Athlete, PubNub) {
      $scope.athlete = Athlete;
      $scope.$on('Context Switch', function(e, context) {
        $scope.visibleMessages = _.contains(['Athlete Profile'], context);
        if ($scope.visibleMessages) {
          return $timeout(function() {
            return $('#messages .history').animate({
              scrollTop: $('#messages .history').get(0).scrollHeight
            }, 1000);
          });
        }
      });
      window.Messages = $scope.history = [];
      $scope.$on('PubNubService : Athlete Connected', function() {
        return PubNub('Messages : Get History', null);
      });
      $scope.$on('Messages : Update History', function(e, data) {
        return window.Messages = $scope.history = data[0];
      });
      $scope.$on('Messages : Incoming Message', function(e, data) {
        return $scope.$evalAsync(function() {
          $scope.history.push(data);
          return $('#messages .history').animate({
            scrollTop: $('#messages .history').get(0).scrollHeight
          }, 2000);
        });
      });
      return $scope.send_message = function() {
        PubNub('Messages : Send Message', {
          sender: Athlete._id,
          text: $scope.message_text
        });
        return $scope.message_text = '';
      };
    }
  ]);


  /*                      Directives */

  app.directive('messages', function() {
    return {
      restrict: 'E',
      templateUrl: 'assets/templates/Messages.html',
      controller: 'MessagesController',
      scope: true,
      replace: true
    };
  });

}).call(this);
