'use strict'
app = angular.module 'PrimaryMenu', ['Athlete']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'PrimaryMenuController', [ '$scope', '$rootScope', 'Athlete', ($scope, $rootScope, Athlete) ->

  $scope.switchContext = (context) -> $rootScope.$broadcast 'Context Switch', context if Athlete._id?
  $scope.$on 'Context Switch', (e, context) ->
    console.log 'Context Switch: ', context
]


###########################################################
###                      Directives                     ###
###########################################################

app.directive 'primaryMenu', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/PrimaryMenu.html'
    controller    : 'PrimaryMenuController'
    scope         : true
  }