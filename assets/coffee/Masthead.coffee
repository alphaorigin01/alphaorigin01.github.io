'use strict'
app = angular.module 'Masthead', []

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'MastheadController', [ '$scope', ($scope) ->
]

###########################################################
###                      Directives                     ###
###########################################################

app.directive 'masthead', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Masthead.html'
    controller    : 'MastheadController'
    scope         : true
  }