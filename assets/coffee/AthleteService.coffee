'use strict'
AthleteService = angular.module 'AthleteService', ['PubNubService']

###########################################################
###                        Service                      ###
###########################################################

AthleteService.factory 'Athlete', [ 'PubNub', '$rootScope', '$http', (PubNub, $rootScope, $http) ->

  window.rootScope = $rootScope

  class Athlete
    constructor  : ->
      that = this
      save = -> if that._rev? then PubNub 'AthleteService : Set Athlete', that
      save = _.debounce save, 1000

      #------------------------------------------
      @stars = {}

      @setStars = (protocol, stars) ->
        PubNub 'ProtocolService : Set Stats', {
          _id      : protocol
          previous : if stars[protocol] then stars[protocol] else 0
          current  : stars
        }
        @stars[protocol] = stars
        do save

      #------------------------------------------
      password = null
      Object.defineProperty this, 'password', {
        enumerable : false
        get        : -> return password
        set        : (x) ->
          first = password is null
          if x isnt password
            password = x
            do save if not first

      }

      #------------------------------------------
      secretKey = crypto.getRandomValues(new Uint8Array(32))
      secretKey.toJSON = -> PUBNUB.raw_encrypt _.flatten(secretKey), password
      Object.defineProperty this, 'secretKey', {
        enumerable : true
        get        : -> return secretKey
        set        : (x) ->
          secretKey = new Uint8Array(PUBNUB.raw_decrypt(x, password))
          secretKey.toJSON = -> PUBNUB.raw_encrypt _.flatten(secretKey), password
      }

      #------------------------------------------
      publicKey = nacl.box.generate_pubkey secretKey
      Object.defineProperty this, 'publicKey', {
        enumerable : false
        get        : -> return publicKey
        set        : (x) -> publicKey = new Uint8Array(x)
      }

      #------------------------------------------
      @favorites = []

      @toggleFavorite = (x) ->
        if _.indexOf( @favorites, x) >= 0
          _.remove @favorites, (n) -> n is x
          do save
        else
          @favorites.push x
          do save

      #------------------------------------------
      height = null
      Object.defineProperty this, 'height', {
        enumerable : true
        get        : -> return height
        set        : (x) ->
          if height isnt x
            height = Math.round( x * 1000 ) / 1000
            do save
        }

      #------------------------------------------
      weight = null
      Object.defineProperty this, 'weight', {
        enumerable : true
        get        : -> return weight
        set        : (x) ->
          if weight isnt x
            weight = Math.round( x * 10 ) / 10
            do save
        }

      #------------------------------------------
      bodyFat = null
      Object.defineProperty this, 'bodyFat', {
        enumerable : true
        get        : -> return bodyFat
        set        : (x) ->
          if bodyFat isnt x
            bodyFat = Math.round( x * 100 ) / 100
            do save
        }

      #------------------------------------------
      ffmiOffset = 0
      Object.defineProperty this, 'ffmiOffset', {
        enumerable : true
        get        : -> return ffmiOffset
        set        : (x) ->
          if ffmiOffset isnt x
            ffmiOffset = Math.round( x * 100 ) / 100
            do save
        }

      #------------------------------------------
      Object.defineProperty this, 'lbm', {
        get: -> @weight * (1 - (@bodyFat * .01))
        set: ->
      }

      #------------------------------------------
      Object.defineProperty this, 'ffmi', {
        get: -> (( @lbm / ( @height * @height )) + ( 6 * ( @height - 1.8 ))) + @ffmiOffset
        set: ->
      }

      #------------------------------------------
      accountBalance = 0
      updateAccountBalance = ->
        $http.get( 'https://blockchain.info/q/addressbalance/' + that.BTCAddress + '?confirmations=6&cors=true' ).success (data) ->
          $rootScope.$evalAsync -> accountBalance = that.accountCredit + ( data / 100000000 )

      Object.defineProperty this, 'accountBalance', {
        get : -> return accountBalance
        set : updateAccountBalance
      }


      $rootScope.$on 'AthleteService : Update Athlete', (e, data) ->
        if data._id is that._id then $rootScope.$evalAsync ->
          that.secretKey = data.secretKey
          if that.secretKey.length isnt 0
            _.extend that, data
            do updateAccountBalance
            $rootScope.$broadcast 'PubNubService : Initialize Athlete'



      $rootScope.$on 'AthleteService : Set Athlete Complete', (e, data) ->
        that._rev = data.rev if data.id is that._id

  window.Athlete = athlete = new Athlete

  $rootScope.$on 'AthleteService : Login', (e, data) ->
    athlete._id = 'athlete_' + data.username
    athlete.password = data.password
    PubNub 'AthleteService : Get Athlete', athlete

  return athlete
]
