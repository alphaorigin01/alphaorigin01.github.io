'use strict'
if window.location.protocol != "https:" then window.location.href = "https:" + window.location.href.substring(window.location.protocol.length)
app = angular.module 'lab', ['Login', 'NewMember', 'PubNubService', 'BTCService', 'OrderService', 'Order', 'AthleteService', 'Athlete', 'Messages', 'ProtocolService', 'Protocol', 'StatusBar', 'PrimaryMenu', 'Masthead', 'ShoppingCart', 'Search', 'ProtocolByID', 'Editor']

###########################################################
###                      Controllers                    ###
###########################################################

###########################################################
###                      Directives                     ###
###########################################################
app.directive 'contenteditable', ->
  {
    require: 'ngModel'
    link: (scope, elm, attrs, ctrl) ->
      elm.bind 'blur', ->
        scope.$evalAsync ->
          ctrl.$setViewValue elm.html()

      elm.bind 'keydown',  (e) ->
        if e.keyCode is 13
          do e.preventDefault
          do e.currentTarget.blur

      elm.bind 'paste', (e) ->
        do e.preventDefault
        window.pastey = elm
        elm[0].innerText = e.originalEvent.clipboardData.getData "text/plain"

      ctrl.$render = ->
        elm.html ctrl.$viewValue
}
