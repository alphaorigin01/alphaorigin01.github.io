'use strict'
app = angular.module 'StatusBar', ['OrderService', 'PubNubService', 'AthleteService']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'StatusBarController', [ '$scope', '$timeout', 'Order', 'PubNub', 'Athlete', ($scope, $timeout, Order, PubNub, Athlete) ->
  $scope.orderStatus = 'None'
  orders = Order.get()
  $scope.athlete = Athlete
  $scope.$on 'OrderService : Update Order', ->

    nike = ->
      return $scope.orderStatus = 'None' if orders.length is 0
      return $scope.orderStatus = 'Complete' if orders[( orders.length - 1 )].fulfillment.complete is true
      return $scope.orderStatus = 'Shipped' if orders[( orders.length - 1 )].fulfillment.shipped is true
      return $scope.orderStatus = 'Payment Needed' if orders[( orders.length - 1 )].fulfillment.paymentRecieved is false
      return $scope.orderStatus = 'Preparing Materials' if orders[( orders.length - 1 )].fulfillment.preparedMaterials is false
      return $scope.orderStatus = 'Formulating Protocols' if orders[( orders.length - 1 )].fulfillment.formulatedProtocols is false
      return $scope.orderStatus = 'Preparing to Ship' if orders[( orders.length - 1 )].fulfillment.shipped is false
    $timeout nike, 100

  $scope.status = 'Offline'
  $scope.$on 'Server : Online', (e, data) ->
    $scope.$evalAsync -> $scope.status = 'Online'

  $scope.processingTime = '2 Weeks'
  $scope.$on 'OrderService : Update Processing Time', (e, data) ->
    $scope.$evalAsync -> $scope.processingTime = data

  $scope.$on 'PubNubService : Connected', ->
    PubNub 'Server : Status', {}
    PubNub 'OrderService : Get Processing Time', {}
]


###########################################################
###                      Directives                     ###
###########################################################

app.directive 'statusBar', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/StatusBar.html'
    controller    : 'StatusBarController'
    scope         : true
  }
