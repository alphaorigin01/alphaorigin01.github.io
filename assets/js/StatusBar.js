// Generated by CoffeeScript 1.9.2
(function() {
  'use strict';
  var app;

  app = angular.module('StatusBar', ['OrderService', 'PubNubService', 'AthleteService']);


  /*                      Controllers */

  app.controller('StatusBarController', [
    '$scope', '$timeout', 'Order', 'PubNub', 'Athlete', function($scope, $timeout, Order, PubNub, Athlete) {
      var orders;
      $scope.orderStatus = 'None';
      orders = Order.get();
      $scope.athlete = Athlete;
      $scope.$on('OrderService : Update Order', function() {
        var nike;
        nike = function() {
          if (orders.length === 0) {
            return $scope.orderStatus = 'None';
          }
          if (orders[orders.length - 1].fulfillment.complete === true) {
            return $scope.orderStatus = 'Complete';
          }
          if (orders[orders.length - 1].fulfillment.shipped === true) {
            return $scope.orderStatus = 'Shipped';
          }
          if (orders[orders.length - 1].fulfillment.paymentRecieved === false) {
            return $scope.orderStatus = 'Payment Needed';
          }
          if (orders[orders.length - 1].fulfillment.preparedMaterials === false) {
            return $scope.orderStatus = 'Preparing Materials';
          }
          if (orders[orders.length - 1].fulfillment.formulatedProtocols === false) {
            return $scope.orderStatus = 'Formulating Protocols';
          }
          if (orders[orders.length - 1].fulfillment.shipped === false) {
            return $scope.orderStatus = 'Preparing to Ship';
          }
        };
        return $timeout(nike, 100);
      });
      $scope.status = 'Offline';
      $scope.$on('Server : Online', function(e, data) {
        return $scope.$evalAsync(function() {
          return $scope.status = 'Online';
        });
      });
      $scope.processingTime = '2 Weeks';
      $scope.$on('OrderService : Update Processing Time', function(e, data) {
        return $scope.$evalAsync(function() {
          return $scope.processingTime = data;
        });
      });
      return $scope.$on('PubNubService : Connected', function() {
        PubNub('Server : Status', {});
        return PubNub('OrderService : Get Processing Time', {});
      });
    }
  ]);


  /*                      Directives */

  app.directive('statusBar', function() {
    return {
      restrict: 'E',
      templateUrl: 'assets/templates/StatusBar.html',
      controller: 'StatusBarController',
      scope: true
    };
  });

}).call(this);
