// Generated by CoffeeScript 1.9.2
(function() {
  'use strict';
  var app;

  app = angular.module('Protocol', ['ProtocolService', 'AthleteService', 'CompoundService', 'PubNubService']);


  /*                     Controllers */

  app.controller('ProtocolController', [
    '$rootScope', '$scope', '$http', '$element', '$timeout', 'Protocol', 'Athlete', 'Compounds', 'PubNub', function($rootScope, $scope, $http, $element, $timeout, Protocol, Athlete, Compounds, PubNub) {
      $scope.tab = 1;
      $scope.selectTab = function(setTab) {
        return $scope.tab = setTab;
      };
      $scope.isSelected = function(checkTab) {
        return $scope.tab === checkTab;
      };
      $scope.formulation_tab = 1;
      $scope.formulation_selectTab = function(setTab) {
        return $scope.formulation_tab = setTab;
      };
      $scope.formulation_isSelected = function(checkTab) {
        return $scope.formulation_tab === checkTab;
      };
      $scope.Athlete = Athlete;
      $scope.Compounds = Compounds;
      $scope.Math = window.Math;
      $scope.active_stars = 0;
      $scope.selected_stars = Athlete.stars[$scope.protocol._id] ? Athlete.stars[$scope.protocol._id] : 0;
      $scope.hover_stars = 0;
      $scope.$on('ProtocolService : Update Stats', function(e, data) {
        if (data.protocol === $scope.protocol._id) {
          return $scope.active_stars = Math.round(data.stars / data.athletes);
        }
      });
      PubNub('ProtocolService : Get Stats', $scope.protocol);
      $scope.set_stars = function(n) {
        $scope.selected_stars = n;
        Athlete.setStars($scope.protocol._id, n);
        return PubNub('ProtocolService : Get Stats', $scope.protocol);
      };
      $scope.calendar = [[1, 2, 3, 4, 5, 6, 7], [71, 72, 73, 74, 75, 76, 77], [8, 9, 10, 11, 12, 13, 14], [78, 79, 80, 81, 82, 83, 84], [15, 16, 17, 18, 19, 20, 21], [85, 86, 87, 88, 89, 90, 91], [22, 23, 24, 25, 26, 27, 28], [92, 93, 94, 95, 96, 97, 98], [29, 30, 31, 32, 33, 34, 35], [99, 100, 101, 102, 103, 104, 105], [36, 37, 38, 39, 40, 41, 42], [106, 107, 108, 109, 110, 111, 112], [43, 44, 45, 46, 47, 48, 49], [113, 114, 115, 116, 117, 118, 119], [50, 51, 52, 53, 54, 55, 56], [120, 121, 122, 123, 124, 125, 126], [57, 58, 59, 60, 61, 62, 63], [127, 128, 129, 130, 131, 132, 133], [64, 65, 66, 67, 68, 69, 70], [134, 135, 136, 137, 138, 139, 140]];
      $scope.selected_day = 1;
      $scope.set_selected_day = function(day) {
        return $scope.selected_day = day;
      };
      $scope.select_next_day = function() {
        return console.log($scope.selected_day += 1);
      };
      $scope.select_previous_day = function() {
        if ($scope.selected_day > 1) {
          return $scope.selected_day -= 1;
        }
      };
      $scope.ordinal = function(day) {
        var s, v;
        s = ["th", "st", "nd", "rd"];
        v = day % 100;
        return s[(v - 20) % 10] || s[v] || s[0];
      };
      $scope.day_has_dose = function(day) {
        return _.isArray($scope.protocol.schedule[day]);
      };
      $scope.dose_for_selected_day = function(id) {
        var day, dose, i, j, len, ref, ref1, ref2, ref3, schedule;
        dose = 0;
        ref = $scope.protocol.formulations[id].schedules;
        for (i = 0, len = ref.length; i < len; i++) {
          schedule = ref[i];
          if (schedule.startDay === $scope.selected_day) {
            dose += schedule.loadingVolume;
          } else {
            for (day = j = ref1 = schedule.startDay, ref2 = (schedule.startDay + schedule.duration) - schedule.interval, ref3 = schedule.interval; ref3 > 0 ? j <= ref2 : j >= ref2; day = j += ref3) {
              if (day === $scope.selected_day) {
                dose += schedule.doseVolume;
              }
            }
          }
        }
        return dose;
      };
      $scope.is_search_results = function() {
        return $($element).parent().attr('id') === 'search_results';
      };
      $scope.toggle_experience_choices_visible = function() {
        if (Athlete._id === $scope.protocol.owner && !$scope.is_search_results()) {
          return $scope.experience_choices_visible = !$scope.experience_choices_visible;
        }
      };
      $scope.toggle_goal_choices_visible = function() {
        if (Athlete._id === $scope.protocol.owner && !$scope.is_search_results()) {
          return $scope.goal_choices_visible = !$scope.goal_choices_visible;
        }
      };
      $scope.add_to_cart_text = function() {
        if ($scope.is_search_results()) {
          return 'View & Buy';
        } else {
          return 'Add To Cart';
        }
      };
      $scope.add_to_cart = function() {
        if ($scope.is_search_results()) {
          return $rootScope.$broadcast('Editor : Focus Protocol', Protocol($scope.protocol._id));
        } else {
          return $rootScope.$broadcast('ShoppingCart : Add Item', $scope.protocol._id);
        }
      };
      $scope.isFavorite = function() {
        return _.indexOf(Athlete.favorites, $scope.protocol._id) >= 0;
      };
      $scope.favorite = function() {
        return Athlete.toggleFavorite($scope.protocol._id);
      };
      return $scope.destroy = function() {
        return Protocol($scope.protocol._id, true);
      };
    }
  ]);

  app.controller('RegimenController', [
    '$scope', '$element', '$timeout', 'Athlete', 'Compounds', function($scope, $element, $timeout, Athlete, Compounds) {
      $scope.increase_interval = function() {
        $scope.regimen.interval = $scope.regimen.interval + 1;
        return $scope.regimen.duration = Math.round($scope.regimen.duration / $scope.regimen.interval) * $scope.regimen.interval;
      };
      $scope.decrease_interval = function() {
        if ($scope.regimen.interval > 1) {
          $scope.regimen.interval = $scope.regimen.interval - 1;
          return $scope.regimen.duration = Math.round($scope.regimen.duration / $scope.regimen.interval) * $scope.regimen.interval;
        }
      };
      $scope.increase_duration = function() {
        return $scope.regimen.duration = $scope.regimen.duration + $scope.regimen.interval;
      };
      $scope.decrease_duration = function() {
        if ($scope.regimen.duration > 1) {
          return $scope.regimen.duration = $scope.regimen.duration - $scope.regimen.interval;
        }
      };
      $($element).find('.value').on('all', function(n) {
        return console.log(n);
      });
      return $($element).find('.value').keydown(function(e) {
        if (e.keyCode === 13) {
          e.preventDefault();
          return e.currentTarget.blur();
        }
      });
    }
  ]);


  /*                      Directives */

  app.directive('dna', function() {
    return {
      restrict: 'A',
      link: function($scope, element, attrs) {
        return $scope.protocol.graph = element;
      }
    };
  });

  app.directive('pharmacodynamics', function() {
    return {
      restrict: 'A',
      link: function($scope, element, attrs) {
        return $scope.protocol.pharmacodynamics = element;
      }
    };
  });

  app.directive('graph', function() {
    return {
      restrict: 'A',
      link: function($scope, element, attrs) {
        return $scope.regimen.graph = element;
      }
    };
  });

  app.directive('protocol', function() {
    return {
      restrict: 'E',
      templateUrl: 'assets/templates/Protocol.html',
      controller: 'ProtocolController',
      scope: true
    };
  });

  app.directive('regimen', function() {
    return {
      restrict: 'E',
      templateUrl: 'assets/templates/Regimen.html',
      controller: 'RegimenController',
      scope: true
    };
  });

}).call(this);
