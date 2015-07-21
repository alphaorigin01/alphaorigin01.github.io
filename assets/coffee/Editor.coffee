'use strict'
app = angular.module 'Editor', ['ProtocolService', 'CompoundService']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'EditorController', ['$scope', '$rootScope', 'Protocol', 'Compounds', ($scope, $rootScope, Protocol, Compounds) ->

  $scope.Compounds = Compounds

  $scope.$on 'Context Switch', (e, context) ->
    $scope.visibleEditor = _.contains ['Editor'], context
    if not $scope.visibleEditor then $scope.$evalAsync -> $scope.protocol = null

  $scope.$on 'Editor : Focus Protocol', (e, protocol) ->
    $scope.protocol = if not protocol? then Protocol() else protocol
    $rootScope.$broadcast 'Context Switch', 'Editor'
    window.Editor = $scope.protocol
    $(window).scrollTop 0

  $scope.$on 'ProtocolService : Delete Protocol Complete', (e, deleted) ->
    return if not $scope.visibleEditor
    if $scope.protocol._id is deleted.id then $scope.$evalAsync -> $rootScope.$broadcast 'Context Switch', 'Search'

  protocolByID = null

]


###########################################################
###                      Directives                     ###
###########################################################

app.directive 'editorSection', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Editor.html'
    controller    : 'EditorController'
    scope         : true
    replace       : true
  }
