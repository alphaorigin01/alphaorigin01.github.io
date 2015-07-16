'use strict'
app = angular.module 'Protocol', ['ProtocolService', 'AthleteService', 'CompoundService', 'PubNubService']

###########################################################
###                     Controllers                     ###
###########################################################

app.controller 'ProtocolController', [ '$rootScope', '$scope', '$http', '$element', '$timeout', 'Protocol', 'Athlete', 'Compounds', 'PubNub', ($rootScope, $scope, $http, $element, $timeout, Protocol, Athlete, Compounds, PubNub) ->
  $scope.tab = 1
  $scope.selectTab = (setTab) ->
    $scope.tab = setTab
  $scope.isSelected = (checkTab) ->
    $scope.tab is checkTab

  $scope.formulation_tab = 1
  $scope.formulation_selectTab = (setTab) ->
    $scope.formulation_tab = setTab
  $scope.formulation_isSelected = (checkTab) ->
    $scope.formulation_tab is checkTab

  $scope.Athlete = Athlete
  $scope.Compounds = Compounds
  $scope.Math = window.Math

  $scope.active_stars = 0
  $scope.selected_stars = if Athlete.stars[$scope.protocol._id] then Athlete.stars[$scope.protocol._id] else 0
  $scope.hover_stars = 0

  $scope.$on 'ProtocolService : Update Stats', (e, data) ->
    if data.protocol is $scope.protocol._id
      $scope.active_stars = Math.round( data.stars / data.athletes )

  PubNub 'ProtocolService : Get Stats', $scope.protocol

  $scope.set_stars = (n) ->
    $scope.selected_stars = n
    Athlete.setStars $scope.protocol._id, n
    PubNub 'ProtocolService : Get Stats', $scope.protocol

  $scope.calendar = [
    [1..7], [71..77]
    [8..14], [78..84]
    [15..21], [85..91]
    [22..28], [92..98]
    [29..35], [99..105]
    [36..42], [106..112]
    [43..49], [113..119]
    [50..56], [120..126]
    [57..63], [127..133]
    [64..70], [134..140]
  ]
  $scope.selected_day = 1
  $scope.set_selected_day = (day) -> $scope.selected_day = day
  $scope.select_next_day = -> console.log $scope.selected_day += 1
  $scope.select_previous_day = -> $scope.selected_day -= 1 if $scope.selected_day > 1
  $scope.ordinal = (day) ->
    s = ["th", "st", "nd", "rd"]
    v = day % 100
    return (s[(v-20)%10]||s[v]||s[0])
  $scope.day_has_dose = (day) -> _.isArray $scope.protocol.schedule[day]
  $scope.dose_for_selected_day = (id) ->
    dose = 0
    for schedule in $scope.protocol.formulations[id].schedules
      if schedule.startDay is $scope.selected_day
        dose += schedule.loadingVolume
      else
        for day in [schedule.startDay..( schedule.startDay + schedule.duration ) - schedule.interval] by schedule.interval
          dose += schedule.doseVolume if day is $scope.selected_day
    return dose

  $scope.is_search_results = -> $($element).parent().attr('id') is 'search_results'
  $scope.toggle_experience_choices_visible = -> $scope.experience_choices_visible = !$scope.experience_choices_visible if Athlete._id is $scope.protocol.owner and not $scope.is_search_results()
  $scope.toggle_goal_choices_visible = -> $scope.goal_choices_visible = !$scope.goal_choices_visible if Athlete._id is $scope.protocol.owner and not $scope.is_search_results()
  $scope.add_to_cart_text = -> if $scope.is_search_results() then 'View & Buy' else 'Add To Cart'
  $scope.add_to_cart = ->
    if $scope.is_search_results()
      $rootScope.$broadcast 'Editor : Focus Protocol', Protocol( $scope.protocol._id )
    else
      $rootScope.$broadcast 'ShoppingCart : Add Item', $scope.protocol._id

  $scope.isFavorite = -> _.indexOf( Athlete.favorites, $scope.protocol._id) >= 0
  $scope.favorite = -> Athlete.toggleFavorite $scope.protocol._id

  $scope.destroy = -> Protocol $scope.protocol._id, true

]



#---------------------------------------------------------#

app.controller 'RegimenController', ['$scope', '$element', '$timeout', 'Athlete', 'Compounds', ($scope, $element, $timeout, Athlete, Compounds) ->
  $scope.increase_interval = ->
    $scope.regimen.interval = $scope.regimen.interval + 1
    $scope.regimen.duration = Math.round($scope.regimen.duration / $scope.regimen.interval) * $scope.regimen.interval

  $scope.decrease_interval = ->
    if $scope.regimen.interval > 1
      $scope.regimen.interval = $scope.regimen.interval - 1
      $scope.regimen.duration = Math.round($scope.regimen.duration / $scope.regimen.interval) * $scope.regimen.interval

  $scope.increase_duration = ->
    $scope.regimen.duration = $scope.regimen.duration + $scope.regimen.interval

  $scope.decrease_duration = ->
    if $scope.regimen.duration > 1
      $scope.regimen.duration = $scope.regimen.duration - $scope.regimen.interval

  $($element).find('.value').on 'all', (n) ->
    console.log n
    
  $($element).find('.value').keydown (e) ->
    if e.keyCode is 13
      e.preventDefault()
      e.currentTarget.blur()

]


###########################################################
###                      Directives                     ###
###########################################################

app.directive('dna', ->
  {
    restrict  : 'A'
    link      : ($scope, element, attrs) ->
      $scope.protocol.graph = element
  }
)

#---------------------------------------------------------#

app.directive('pharmacodynamics', ->
  {
    restrict  : 'A'
    link      : ($scope, element, attrs) ->
      $scope.protocol.pharmacodynamics = element
  }
)

#---------------------------------------------------------#

app.directive('graph', ->
  {
    restrict  : 'A'
    link      : ($scope, element, attrs) ->
      $scope.regimen.graph = element
  }
)

#---------------------------------------------------------#

app.directive 'protocol', ->
  {
    restrict      : 'E'
    templateUrl   : 'assets/templates/Protocol.html'
    controller    : 'ProtocolController'
    scope         : true
  }

#---------------------------------------------------------#

app.directive 'regimen', ->
  {
    restrict    : 'E'
    templateUrl : 'assets/templates/Regimen.html'
    controller    : 'RegimenController'
    scope         : true
  }