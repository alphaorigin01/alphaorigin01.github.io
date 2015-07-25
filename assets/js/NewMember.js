// Generated by CoffeeScript 1.9.2
(function() {
  'use strict';
  var app;

  app = angular.module('NewMember', ['AthleteService', "PubNubService"]);


  /*                      Controllers */

  app.controller('NewMemberController', [
    '$scope', '$rootScope', '$timeout', 'Athlete', 'PubNub', function($scope, $rootScope, $timeout, Athlete, PubNub) {
      window.NewMember = $scope;
      $scope.athlete = Athlete;
      $scope.$on('Server : Online', function() {
        return $scope.$evalAsync(function() {
          if (Athlete._rev == null) {
            return $scope.visibleNewMember = true;
          }
        });
      });
      $scope.$on('Context Switch', function() {
        return $scope.visibleNewMember = false;
      });
      $scope.$watch('username', function() {
        if (($scope.username != null) && $scope.username !== '') {
          return PubNub('AthleteService : Check Athlete ID', $scope.username);
        } else {
          $scope.usernameValid = false;
          return $scope.usernameInvalid = false;
        }
      });
      $scope.$watch('password', function() {
        return $scope.passwordValid = ($scope.password != null) && $scope.password !== '' && $scope.password.length > 5 ? true : false;
      });
      $scope.$watch('invitation', function() {
        if (($scope.invitation != null) && $scope.invitation !== '') {
          return PubNub('AthleteService : Check Invitation', $scope.invitation);
        } else {
          $scope.invitationValid = false;
          return $scope.invitationInvalid = false;
        }
      });
      $scope.$on('AthleteService : Athlete ID Available', function(e, data) {
        if ($scope.username === data) {
          return $scope.$evalAsync(function() {
            $scope.usernameValid = true;
            return $scope.usernameInvalid = false;
          });
        }
      });
      $scope.$on('AthleteService : Athlete ID Unavailable', function(e, data) {
        if ($scope.username === data) {
          return $scope.$evalAsync(function() {
            $scope.usernameValid = false;
            return $scope.usernameInvalid = true;
          });
        }
      });
      $scope.$on('AthleteService : Invitation Is Valid', function(e, data) {
        if ($scope.invitation === data) {
          return $scope.$evalAsync(function() {
            $scope.invitationValid = true;
            return $scope.invitationInvalid = false;
          });
        }
      });
      $scope.$on('AthleteService : Invitation Is Invalid', function(e, data) {
        if ($scope.invitation === data) {
          return $scope.$evalAsync(function() {
            $scope.invitationValid = false;
            return $scope.invitationInvalid = true;
          });
        }
      });
      $scope.buttonStatus = function() {
        if (($scope.username == null) || $scope.username === '') {
          return 'Select A Username';
        }
        if ($scope.usernameInvalid) {
          return 'Username Already Taken';
        }
        if (!$scope.passwordValid) {
          return 'Enter a valid password';
        }
        if (($scope.invitation == null) || $scope.invitation === '') {
          return 'Enter your invitation code';
        }
        if ($scope.invitationInvalid) {
          return 'Invitation code is invalid';
        }
        if ((Athlete.height == null) || Athlete.height === 0) {
          return 'Enter your height';
        }
        if ((Athlete.weight == null) || Athlete.weight === 0) {
          return 'Enter your weight';
        }
        if ((Athlete.bodyFat == null) || Athlete.bodyFat === 0) {
          return 'Enter your bodyfat';
        }
        return 'Request Membership';
      };
      return $scope.requestMembership = function() {
        if (($scope.buttonStatus()) === 'Request Membership') {
          Athlete._id = 'athlete_' + $scope.username;
          Athlete.invitation = $scope.invitation;
          Athlete.password = $scope.password;
          return PubNub('AthleteService : New Athlete', Athlete);
        }
      };
    }
  ]);


  /*                      Directives */

  app.directive('newMemberSection', function() {
    return {
      restrict: 'E',
      templateUrl: 'assets/templates/NewMember.html',
      controller: 'NewMemberController',
      scope: true,
      replace: true
    };
  });

}).call(this);
