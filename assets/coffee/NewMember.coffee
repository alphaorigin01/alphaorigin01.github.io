'use strict'
app = angular.module 'NewMember', ['AthleteService', "PubNubService"]

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'NewMemberController', [ '$scope', '$rootScope', '$timeout', 'Athlete', 'PubNub', ($scope, $rootScope, $timeout, Athlete, PubNub) ->
  window.NewMember = $scope
  $scope.athlete = Athlete

  $scope.$on 'Server : Online', ->
    $scope.$evalAsync -> $scope.visibleNewMember = true if not Athlete._rev?

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

  $scope.buttonStatus = ->
    return 'Select A Username' if not $scope.username? or $scope.username is ''
    return 'Username Already Taken' if $scope.usernameInvalid
    return 'Enter a valid password' if not $scope.passwordValid
    return 'Enter your invitation code' if not $scope.invitation? or $scope.invitation is ''
    return 'Invitation code is invalid' if $scope.invitationInvalid
    return 'Enter your height' if not Athlete.height? or Athlete.height is 0
    return 'Enter your weight' if not Athlete.weight? or Athlete.weight is 0
    return 'Enter your bodyfat' if not Athlete.bodyFat? or Athlete.bodyFat is 0
    return 'Request Membership'

  $scope.requestMembership = ->
    if ($scope.buttonStatus()) is 'Request Membership'
      Athlete._id = 'athlete_' + $scope.username
      Athlete.invitation = $scope.invitation
      Athlete.password = $scope.password
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
