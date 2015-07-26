'use strict'
app = angular.module 'Order', ['ProtocolService', 'AthleteService', 'CompoundService', 'BTCService']

###########################################################
###                     Controllers                     ###
###########################################################

app.controller 'OrderController', [ '$rootScope', '$scope', '$http', '$element', '$timeout', 'BTCrate', 'Protocol', 'Athlete', 'Compounds', 'Order', ($rootScope, $scope, $http, $element, $timeout, BTCrate, Protocol, Athlete, Compounds, Order) ->
  $scope.orders = Order.get()
  $scope.BTCrate = BTCrate
  $scope.Athlete = Athlete
  $scope.Compounds = Compounds

  $scope.$on 'Context Switch', (e, context) ->
    $scope.visibleOrders = _.contains ['Athlete Profile'], context

  $scope.statusIsPayment = (i) ->
    $scope.orders[i].fulfillment.paymentRecieved is false

  $scope.statusIsFormulating = (i) ->
    $scope.orders[i].fulfillment.paymentRecieved is true and $scope.orders[i].fulfillment.shipped is false

  $scope.statusIsShipped = (i) ->
    $scope.orders[i].fulfillment.shipped is true

  $scope.shippingBarLength = (i) ->
    return '0' if not Orders[i].trackingInfo?
    today = new Date()
    start =  _.last(Orders[i].trackingInfo.history).date
    finish = Orders[i].trackingInfo.deliveryDay
    full = finish - start
    now = if ( finish - today ) < 0 then ( finish - start ) else ( finish - today )
    if ( now / full ) > 1
      return '34rem'
    else
      return ( ( now / full ) * 34 ) + 'rem'

]


###########################################################
###                      Directives                     ###
###########################################################

app.directive('ordersSection', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Order.html'
    controller    : 'OrderController'
    scope         : true
    replace       : true
  }
)

#---------------------------------------------------------#
