'use strict'
app = angular.module 'Messages', ['AthleteService', 'PubNubService']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'MessagesController', [ '$scope', '$rootScope', '$timeout', 'Athlete', 'PubNub', ($scope, $rootScope, $timeout, Athlete, PubNub) ->
  $scope.athlete = Athlete
  $scope.$on 'Context Switch', (e, context) ->
    $scope.visibleMessages = _.contains ['Athlete Profile'], context
    if $scope.visibleMessages then $timeout ->
      $('#messages .history').animate {
        scrollTop : $('#messages .history').get(0).scrollHeight
      }, 1000

  window.Messages = $scope.history = []
  $scope.$on 'PubNubService : Athlete Connected', ->
    PubNub 'Messages : Get History', null
  $scope.$on 'Messages : Update History', (e, data) ->
    window.Messages = $scope.history = data[0]
  $scope.$on 'Messages : Incoming Message', (e, data) ->
    $scope.$evalAsync ->
      $scope.history.push data
      $('#messages .history').animate {
        scrollTop : $('#messages .history').get(0).scrollHeight
      }, 2000

  $scope.send_message = ->
    PubNub 'Messages : Send Message', {
      sender : Athlete._id
      text : $scope.message_text
    }

    $scope.message_text = ''

]


###########################################################
###                      Directives                     ###
###########################################################

app.directive 'messages', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Messages.html'
    controller    : 'MessagesController'
    scope         : true
    replace       : true
  }