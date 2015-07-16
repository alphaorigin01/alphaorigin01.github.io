'use strict'
OrderService = angular.module 'OrderService', ['ProtocolService', 'AthleteService', 'PubNubService', 'BTCService' ]

###########################################################
###                        Service                      ###
###########################################################

OrderService.factory 'Order', [ 'Protocol', 'Athlete', 'PubNub', 'BTCrate', '$rootScope', '$timeout', (Protocol, Athlete, PubNub, BTCrate, $rootScope, $timeout) ->
  class Order
    constructor : () ->
      @_id = 'order_' + Athlete._id + '_' +  Date.now().toString(36).toUpperCase()
      @date = new Date

      @type = 'Order'
      @cart = {}
      @accessoryQty = 0
      @accessoryPriceUSD = 0
      @grandTotal = 0
      @referral = ''
      @name = ''
      @address = ''
      @address2 = ''
      @city = ''
      @state = ''
      @zip = ''
      @fulfillment = {
        paymentRecieved : false
        paymentTimestamp : ''
        preparedMaterials : false
        formulatedProtocols : false
        shipped : false
        shippedTimestamp : ''
        tracking : ''
        complete : false
      }

      that = this
      $rootScope.$on 'OrderService : Update Tracking Info', (e, data) ->
        if data.id is that._id
          $rootScope.$evalAsync ->
            that.trackingInfo = data.trackingInfo
            that.trackingInfo.deliveryDay = new Date that.trackingInfo.deliveryDay
            for item in that.trackingInfo.history
              item.date = new Date item.date

      $rootScope.$on 'OrderService : Update Order', (e, data) ->
        if data._id is that._id
          $rootScope.$evalAsync ->
            _.extend that, data
            if that.fulfillment.shipped then PubNub 'OrderService : Get Tracking Info', that._id


    place : ->
      if not @_rev? then PubNub 'OrderService : Place Order', this

  window.Orders = orders = []
  $rootScope.$on 'PubNubService : Athlete Connected', ->
    PubNub 'OrderService : Get Order List', Athlete

  $rootScope.$on 'OrderService : Update Order List', (e, data) ->
    $rootScope.$evalAsync ->
      orders.splice 0, orders.length
      for order in data
        orders.push o = new Order Athlete._id
        o._id = order.id
        PubNub 'OrderService : Get Order', order.id
      orders.reverse()

  $rootScope.$on 'OrderService : Order Placed', ->
    PubNub 'OrderService : Get Order List', Athlete
    
  return {
    create : ->
      return new Order( Athlete._id )
    get    : ->
      return orders
  }

]
