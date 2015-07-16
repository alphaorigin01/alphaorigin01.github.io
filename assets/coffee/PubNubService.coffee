'use strict'
window.nacl = nacl = require('ecma-nacl')
PubNubService = angular.module 'PubNubService', []

###########################################################
###                        Service                      ###
###########################################################

PubNubService.factory 'PubNub', [ '$rootScope', ($rootScope) ->

  window.textEncoder = textEncoder = new TextEncoder()
  window.textDecoder = textDecoder = new TextDecoder()

  window.athlete_skey = athlete_skey = new Uint8Array([198, 131, 161, 40, 127, 182, 95, 120, 238, 21, 211, 246, 62, 165, 73, 88, 127, 193, 29, 193, 60, 198, 183, 255, 187, 234, 222, 180, 206, 115, 50, 11]) # crypto.getRandomValues( new Uint8Array(32) )
  window.athlete_pkey = athlete_pkey = nacl.box.generate_pubkey athlete_skey

  _encryptor = null
  Encrypt = (message) ->
    message_string = JSON.stringify message
    message_bytes  = textEncoder.encode message_string
    message_cipher = _encryptor.pack message_bytes
    return _.flatten message_cipher


  _decryptor = null
  Decrypt = (received_cipher) ->
    received_cipher = new Uint8Array( received_cipher )
    message_bytes  = _decryptor.open received_cipher
    message_string = String.fromCharCode.apply null, message_bytes
    return message = JSON.parse message_string

  pubnub_broadcast_config = {
    origin        : 'rebtelsdk.pubnub.com'
    ssl           : true
    publish_key   : 'pub-c-0ad3b937-16a4-4563-819a-d9c108daf8a1'
    subscribe_key : 'sub-c-cf1ec346-a876-11e2-80da-12313f022c90'
    cipher_key    : 'sample'
  }

  window.PubNub = $rootScope.PubNub = PubNub = PUBNUB.init pubnub_broadcast_config
  do PubNub.ready

  ServerPublicKey = ''
  $rootScope.$on 'Server : Online', (e, data) -> window.ServerPublicKey = ServerPublicKey = new Uint8Array( data )

  PubNub.subscribe {
    channel  : '8e04b18a-f27f-430e-a772-6f91c5302ca'
    callback : (message) ->
      $rootScope.$broadcast message.action, message.data
    connect  : ->
      $rootScope.$broadcast 'PubNubService : Connected'
  }

  $rootScope.$on 'PubNubService : Initialize Athlete', ->
    nonce = new Uint8Array(24)
    crypto.getRandomValues nonce
    _decryptor = nacl.box.formatWN.makeDecryptor ServerPublicKey, Athlete.secretKey, nacl.arrays.makeFactory()
    _encryptor = nacl.box.formatWN.makeEncryptor ServerPublicKey, Athlete.secretKey, nonce, 2, nacl.arrays.makeFactory()


    PubNub.subscribe {
      channel  : Athlete.channel
      callback : (message) ->
        message = Decrypt message
        $rootScope.$broadcast message.action, message.data
      connect  : ->
        $rootScope.$evalAsync -> $rootScope.$broadcast 'PubNubService : Athlete Connected'
    }

    PubNub.subscribe {
      channel  : Athlete.channel + 'S'
      callback : (message) ->
        $rootScope.$broadcast 'Messages : Incoming Message', message
    }

  return (action, data) ->
    server_direct = [
      'Server : Status'
      'Server : Get BTCrate'
      'AthleteService : Check Athlete ID'
      'AthleteService : New Athlete'
      'AthleteService : Get Athlete'
      'OrderService : Get Processing Time'
    ]

    if action.startsWith('Messages : ')
      switch action
        when 'Messages : Get History'
          PubNub.history {
            channel  : Athlete.channel + 'S'
            callback : (m) ->
              $rootScope.$broadcast 'Messages : Update History', m
          }
        when 'Messages : Send Message'
          PubNub.publish {
            channel : Athlete.channel + 'S'
            message : data
          }
          PubNub.publish {
            channel : '8e04b18a-f27f-430e-a772-6f91c5302caS'
            message : data
          }
    else
      message = {
        action : action
        data : data
      }
      if server_direct.indexOf( action ) is -1
        lastRequest = new Date()
        PubNub.publish {
          channel : Athlete.channel
          message : Encrypt(message)
        }
      else
        PubNub.publish {
          channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
          message : message
        }

]
