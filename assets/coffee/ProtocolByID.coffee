'use strict'
app = angular.module 'ProtocolByID', []

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'ProtocolByIDController', [ '$scope', '$rootScope', 'PubNub', ($scope, $rootScope, PubNub) ->
  $scope.visibleSearch = false
  $scope.$on 'Context Switch', (e, context) ->
    $scope.visibleSearch = _.contains ['Search'], context
    
  $scope.searchProtocolByID = ->
    PubNub 'ProtocolService : Search', {
      q : 'id:' + 'protocol_' + if $scope.protocolByID.startsWith('X-') then $scope.protocolByID.substring(2) else $scope.protocolByID
    }
]

###########################################################
###                      Directives                     ###
###########################################################
app.directive 'protocolById', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/ProtocolByID.html'
    controller    : 'ProtocolByIDController'
    replace       : true
  }