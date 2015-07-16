'use strict'
app = angular.module 'NewMember', ['AthleteService', "PubNubService"]

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'NewMemberController', [ '$scope', '$rootScope', '$timeout', 'Athlete', 'PubNub', ($scope, $rootScope, $timeout, Athlete, PubNub) ->
  window.NewMember = $scope
  $scope.athlete = Athlete
  $scope.$on 'Server : Online', ->
    $scope.$evalAsync -> $scope.visibleNewMember = true
    
  $scope.$on 'Context Switch', -> $scope.visibleNewMember = false

  $scope.$watch 'username', ->
    if $scope.username? and $scope.username isnt ''
      PubNub 'AthleteService : Check Athlete ID', $scope.username
    else
      $scope.usernameValid = false
      $scope.usernameInvalid = false

  $scope.$watch 'password', ->
    $scope.passwordValid = if $scope.password? and $scope.password isnt '' and $scope.password.length > 5 then true else false

  $scope.$watch 'invitation', ->
    if $scope.invitation? and $scope.invitation isnt ''
      PubNub 'AthleteService : Check Invitation', $scope.invitation
    else
      $scope.invitationValid = false
      $scope.invitationInvalid = false

  $scope.$on 'AthleteService : Athlete ID Available', (e, data) ->
    if $scope.username is data
      $scope.$evalAsync ->
        $scope.usernameValid = true
        $scope.usernameInvalid = false

  $scope.$on 'AthleteService : Athlete ID Unavailable', (e, data) ->
    if $scope.username is data
      $scope.$evalAsync ->
        $scope.usernameValid = false
        $scope.usernameInvalid = true

  $scope.$on 'AthleteService : Invitation Is Valid', (e, data) ->
    if $scope.invitation is data
      $scope.$evalAsync ->
        $scope.invitationValid = true
        $scope.invitationInvalid = false

  $scope.$on 'AthleteService : Invitation Is Invalid', (e, data) ->
    if $scope.invitation is data
      $scope.$evalAsync ->
        $scope.invitationValid = false
        $scope.invitationInvalid = true

  $scope.requestMembership = ->
    if Athlete.height? and Athlete.height > 0 and Athlete.weight? and Athlete.weight > 0 and Athlete.bodyFat? and Athlete.bodyFat > 0 and $scope.usernameValid and $scope.passwordValid and $scope.invitationValid
      Athlete._id = 'athlete_' + $scope.username
      Athlete.invitation = $scope.invitation
      PubNub 'AthleteService : New Athlete', Athlete

]

###########################################################
###                      Directives                     ###
###########################################################

app.directive 'newMemberSection', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/NewMember.html'
    controller    : 'NewMemberController'
    scope         : true
    replace       : true
  }