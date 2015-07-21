'use strict'
app = angular.module 'Login', ['AthleteService']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'LoginController', [ '$scope', '$rootScope', 'Athlete', ($scope, $rootScope, Athlete) ->
  $scope.$on 'Server : Online', ->
    $scope.$evalAsync -> $scope.visibleLogin = true if not Athlete._rev?

  $scope.login = ->
    return if not $scope.username? or $scope.username is '' or not $scope.password? or $scope.password is ''
    $rootScope.$broadcast 'AthleteService : Login', {
      username : $scope.username
      password : $scope.password
    }

  $('.password').bind 'keydown',  (e) ->
    if e.keyCode is 13
      e.preventDefault()
      do $scope.login

  $scope.$on 'Context Switch', -> $scope.visibleLogin = false
]


###########################################################
###                      Directives                     ###
###########################################################

app.directive 'login', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Login.html'
    controller    : 'LoginController'
    scope         : true
    replace       : true
  }
