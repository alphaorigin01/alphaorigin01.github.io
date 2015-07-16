'use strict'
app = angular.module 'ShoppingCart', ['OrderService', 'ProtocolService', 'AthleteService', 'CompoundService', 'BTCService', 'PubNubService']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'ShoppingCartController', [ '$scope', '$rootScope', '$element', 'BTCrate', 'Athlete', 'Protocol', 'Compounds', 'Order', 'PubNub', ($scope, $rootScope, $element, BTCrate, Athlete, Protocol, Compounds, Order, PubNub) ->

  $scope.BTCrate = BTCrate
  window.ShoppingCart = $scope.order = Order.create()
  $scope.$on 'PubNubService : Athlete Connected', ->
    window.ShoppingCart = $scope.order = Order.create()
  $scope.Compounds = Compounds

  $scope.$on 'Context Switch', (e, context) ->
    $scope.visibleShoppingCart = _.contains ['Search', 'Editor'], context

  $scope.$on 'ShoppingCart : Add Item', (e, id) ->
    if not $scope.order.cart[id]?
      $scope.order.cart[id] = {
        qty : 1
        protocol : Protocol id
      }
    else
      $scope.order.cart[id].qty += 1

  $scope.$watch 'order.referral', ->
    if $scope.order.referral? and $scope.order.referral isnt ''
      PubNub 'OrderService : Verify Referral Code', $scope.order.referral

  $scope.$on 'OrderService : Referral Code Is Valid', (e, data) ->
    if data is $scope.order.referral then $scope.$evalAsync -> $scope.referralCodeValid = true

  $scope.$on 'OrderService : Referral Code Is Invalid', (e, data) ->
    if data is $scope.order.referral then $scope.$evalAsync -> $scope.referralCodeValid = false

  $scope.increaseQty = (i) -> $scope.order.cart[i].qty += 1
  $scope.decreaseQty = (i) -> if $scope.order.cart[i].qty > 1 then $scope.order.cart[i].qty -= 1
  $scope.deleteItem  = (i) -> delete $scope.order.cart[i]

  $scope.accessoryQty = ->
    qty = 0
    _.each $scope.order.cart, (item) -> qty += item.qty * item.protocol.accessoriesQty
    $scope.order.accessoryQty = qty
    return qty

  $scope.accessoryPriceUSD = ->
    return 0 if $scope.accessoryQty() is 0
    return 0 if $scope.referralCodeValid is true
    price = $scope.accessoryQty() * 0.2 # needles and alcohol pads
    price += 10 # shipping
    price += 3 # sharps container and misc.
    return price

  $scope.grandTotal = ->
    total = 0
    _.each $scope.order.cart, (item) ->
      total += item.protocol.priceUSD * item.qty
    total += $scope.accessoryPriceUSD()
    return total

  $scope.orderReady = ->
    if _.isEmpty $scope.order.cart
      return [false, 'Add A Protocol']
    if $scope.order.name.length > 0 and $scope.order.address.length > 0 and $scope.order.city.length > 0 and $scope.order.state.length is 2 and $scope.order.zip.length >= 5
      return [true, 'Checkout']
    else
      return [false, 'Address Incomplete']

  $scope.checkout = ->
    if $scope.orderReady()[0]
      $scope.order.grandTotal = $scope.grandTotal()
      $scope.order.accessoryQty = $scope.accessoryQty()
      $scope.order.place()
      window.ShoppingCart = $scope.order = Order.create()
      $rootScope.$broadcast 'Context Switch', 'Athlete Profile'
]


###########################################################
###                      Directives                     ###
###########################################################

app.directive 'shoppingCart', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/ShoppingCart.html'
    controller    : 'ShoppingCartController'
    controllerAs  : 'ShoppingCartCtrl'
    scope         : true
    replace       : true
  }