'use strict'
BTCService = angular.module 'BTCService', ['PubNubService']

###########################################################
###                        Service                      ###
###########################################################

BTCService.factory 'BTCrate', ['$http', '$interval', '$rootScope', 'PubNub', ($http, $interval, $rootScope, PubNub) ->
  rate = 0

  $rootScope.$on 'BTCService : Update BTCrate', (e, data) ->
    $rootScope.$evalAsync -> rate = 1 / data.amount

  $rootScope.$on 'PubNubService : Connected', ->
    PubNub 'Server : Get BTCrate', {}

  window.BTCService = -> return rate
  return -> return rate
]