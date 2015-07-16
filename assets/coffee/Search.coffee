'use strict'
app = angular.module 'Search', ['Search', 'AthleteService', 'ProtocolService', 'PubNubService', 'CompoundService']

###########################################################
###                      Controllers                    ###
###########################################################

app.controller 'SearchController', [ '$scope', '$rootScope', '$timeout', 'Athlete', 'Protocol', 'PubNub', 'Compounds', ($scope, $rootScope, $timeout, Athlete, Protocol, PubNub, Compounds) ->
  tab = 1

  $scope.selectTab = (setTab) ->
    $scope.$evalAsync ->
      $scope.searchResults = []
      switch setTab
        when 1
          PubNub 'ProtocolService : Search', {
            q : 'owner:' + 'athlete_alpha'
          }
        when 2 then $scope.showFavorites()
        when 3
          PubNub 'ProtocolService : Search', {
            q : 'owner:' + Athlete._id
          }
    tab = setTab

  $scope.isSelected = (checkTab) ->
    tab is checkTab

  $scope.$on 'Context Switch', (e, context) ->
    $scope.visibleSearch = _.contains ['Search'], context

  $scope.minDays = 1
  $scope.maxDays = 140

  $scope.$on 'PubNubService : Athlete Connected', ->
    $timeout ->
      $scope.experience = 'Beginner' if Athlete.ffmi < 20
      $scope.experience = 'Intermediate' if 25 > Athlete.ffmi >= 20
      $scope.experience = 'Advanced' if Athlete.ffmi >= 25
      do $scope.showFavorites
      $scope.selectTab 2

  $scope.Compounds = Compounds

  createNewProtocol = -> $rootScope.$broadcast 'Editor : Focus Protocol'
  $scope.createNewProtocol = _.debounce createNewProtocol, 2000, true

  searchResultsQueue = []
  $scope.searchResults = []
  window.Search = $scope

  $scope.searchCompounds = [null, null]
  $scope.searchCompoundName = (i) ->
    if $scope.searchCompounds[i]?
      Compounds( $scope.searchCompounds[i] ).name
    else
      'Search By Compound'
  $scope.searchCompoundColor = (i) ->
    if $scope.searchCompounds[i]?
      Compounds( $scope.searchCompounds[i] ).color
    else
      'none'
  $scope.toggleSearchCompound = (i) ->
    if $scope.searchCompounds[i]?
      $scope.searchCompounds[i] = null
      do $scope.search
    else
      $scope.choose_compound = true
      $scope.choose_compound_for = i
  $scope.chooseCompound = (id) ->
    $scope.searchCompounds[ $scope.choose_compound_for ] = id
    do $scope.search

  $scope.search = ->
    goals = if not $scope.strength and not $scope.hypertrophy and not $scope.recomposition and not $scope.performance then [ 'Strength', 'Hypertrophy', 'Recomposition', 'Performance' ] else []
    goals.push 'Strength' if $scope.strength
    goals.push 'Hypertrophy' if $scope.hypertrophy
    goals.push 'Recomposition' if $scope.recomposition
    goals.push 'Performance' if $scope.performance

    compounds = ''
    compounds = ' AND compound:' + $scope.searchCompounds[0] if $scope.searchCompounds[0]? and not $scope.searchCompounds[1]?
    compounds = ' AND compound:' + $scope.searchCompounds[1] if $scope.searchCompounds[1]? and not $scope.searchCompounds[0]?
    compounds = ' AND compound:(' + $scope.searchCompounds[1] + ' AND ' + $scope.searchCompounds[0] + ')' if $scope.searchCompounds[0]? and $scope.searchCompounds[1]?

    PubNub 'ProtocolService : Search', {
      q : 'length:[' + $scope.minDays + ' TO ' + $scope.maxDays + '] AND experience:' + $scope.experience + ' AND goal:(' + goals.toString().replace(/,/g, ' OR ') + ') AND ' + (if tab is 3 then ( 'owner:' + Athlete._id ) else 'public:true' + compounds )
    }

  populate = ->
    $scope.searchResults.push( searchResultsQueue.shift() ) if searchResultsQueue.length > 0
    $timeout -> do populate if searchResultsQueue.length > 0 and $('#search_results')[0].getBoundingClientRect().bottom <= $(window).height()

  $scope.showFavorites = ->
    searchResultsQueue = []
    searchResultsQueue.push( Protocol( id ) ) for id in Athlete.favorites
    do populate

  $(window).scroll -> if $scope.visibleSearch then do populate

  $scope.$on 'ProtocolService : Search Results', (e, data) ->
    $scope.$evalAsync ->
      searchResultsQueue.push( Protocol( result.id ) ) for result in data.rows
      $scope.searchResults = []
      do populate

  $scope.$on 'ProtocolService : Delete Protocol Complete', $scope.search

]


###########################################################
###                      Directives                     ###
###########################################################
app.directive 'searchSection', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Search.html'
    controller    : 'SearchController'
    scope         : true
    replace       : true
  }
