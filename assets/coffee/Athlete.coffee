'use strict'
app = angular.module 'Athlete', ['AthleteService', 'BTCService', 'PubNubService']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'AthleteMetricsController', ['$scope', '$element', 'Athlete', 'BTCrate', 'PubNub', ($scope, $element, Athlete, BTCrate, PubNub) ->
  $scope.athlete = Athlete
  $scope.balanceInBTC = Athlete.accountCredit

  $scope.balanceInUSD = -> Athlete.accountBalance / BTCrate()

  scrollMessages = ->
    $('#messages > .history').scrollTop $('#messages > .history')[0].scrollHeight

  $('.dial').knob()
  $scope.$on 'AthleteService : Set Athlete', (e, context) ->
    $('.lean_body_mass').find('.dial').val(Athlete.lbm).trigger 'change'
    $('.fat_free_mass_index').find('.dial').val(Athlete.ffmi).trigger 'change'

  $scope.$on 'Context Switch', (e, context) ->
    $scope.visibleAthleteMetricsAside = _.contains ['Search', 'Editor'], context
    $scope.visibleAccount = _.contains ['Athlete Profile'], context
    $scope.visibleAthleteMetrics = _.contains ['Athlete Profile'], context

  $scope.generateInvitation = ->
    PubNub 'AthleteService : New Invitation', { athlete : Athlete._id }

  $scope.$on 'AthleteService : Invitation Generated', (e, data) ->
    $scope.$evalAsync -> if data.athlete is Athlete._id then $scope.invitationCode = data._id.substring(11)

  $scope.savePassword = ->
    Athlete.password = $scope.newPassword if $scope.newPassword? and $scope.newPassword isnt ''

  $scope.$on 'AthleteService : Set Athlete Complete', ->
    $scope.$evalAsync -> $scope.newPassword = ''
]


###########################################################
###                      Directives                     ###
###########################################################

app.directive 'athleteMetricsSection', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/AthleteMetrics.html'
    controller    : 'AthleteMetricsController'
    scope         : true
    replace       : true
  }

app.directive 'athleteMetricsAside', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/AthleteMetricsAside.html'
    controller    : 'AthleteMetricsController'
    scope         : true
    replace       : true
  }

app.directive 'account', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Account.html'
    controller    : 'AthleteMetricsController'
    scope         : true
    replace       : true
  }
