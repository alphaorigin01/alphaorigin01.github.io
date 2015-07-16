_ = require 'lodash'
###########################################################
###                       Tracking                      ###
###########################################################
cheerio = require("cheerio")
getTrackingInfo = (order, cb) ->
  if order.fulfillment.tracking isnt ''
    request 'https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=' + order.fulfillment.tracking, (error, response, body) ->
      trackingInfo = {
        history : []
      }

      $ = cheerio.load body, { normalizeWhitespace: true }
      trackingInfo.deliveryDay = $('div.tracking-progress span.value:nth-child(2)').text()
      $('.detail-wrapper').each ->
        trackingInfo.history.push {
          date : $(this).find('.date-time').text()
          status : $(this).find('.status').text()
        }

      cb trackingInfo


###########################################################
###                        PubNub                       ###
###########################################################

pubnubBroadcastConfig = {
  origin        : 'rebtelsdk.pubnub.com'
  ssl           : true
  publish_key   : 'pub-c-0ad3b937-16a4-4563-819a-d9c108daf8a1'
  subscribe_key : 'sub-c-cf1ec346-a876-11e2-80da-12313f022c90'
  cipher_key    : 'sample'
  uuid          : '8e04b18a-f27f-430e-a772-6f91c5302ca'
}

PubNub = require("pubnub") pubnubBroadcastConfig


###########################################################
###                        Bitcore                      ###
###########################################################

bitcore = require("bitcore")


###########################################################
###                       Hangups                       ###
###########################################################
Client = require 'hangupsjs'
Q      = require 'q'
creds  = -> auth:Client.authStdin
hangouts = new Client()
hangouts.on 'chat_message', (msg) ->
  console.log '======> Hangouts Message: ', msg#.chat_message.message_content.segment[0].text
  parse = msg.chat_message.message_content.segment[0].text.split(':: ')
  if parse.length is 2
    AlphaDB.get 'athlete_' + parse[0], (e, athlete) ->
      if e?
        hangouts.sendchatmessage 'UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'Message error.']]
      else
        PubNub.publish {
          channel : athlete.channel + 'S'
          message : {
            sender : 'athlete_Alpha'
            text   : parse[1]
          }
        }
hangouts.on 'connected', ->
  hangouts.setactiveclient true, 1000
  #hangouts.sendchatmessage 'UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'Server is up.']]

do reconnect = ->
  hangouts.connect(creds)

hangouts.on 'connect_failed', -> setTimeout reconnect, 3000


###########################################################
###                       CoinBase                      ###
###########################################################

request = require("request")
CoinBaseData = {}

do UpdateCoinBaseData = ->
  request 'https://api.coinbase.com/v1/prices/sell?qty=1', (error, response, body) ->
    try CoinBaseData = JSON.parse body
    console.log 'CoinBaseData: ', CoinBaseData

setInterval UpdateCoinBaseData, 300000


###########################################################
###                       Cloudant                      ###
###########################################################

Cloudant = require('nano')('https://timothyjoelwright.cloudant.com')
AlphaDB = null

do UpdateCloudant = -> 
  Cloudant.auth 'timothyjoelwright', 'BfIQ6JX3CAfBmCx', (err, response, headers) ->
    try cookie = headers['set-cookie']
    console.log 'cookie: ', cookie
    Cloudant = require('nano')({ url : 'https://timothyjoelwright.cloudant.com', cookie: cookie })

    AlphaDB = Cloudant.use 'alpha'

setInterval UpdateCloudant, 3600000

###########################################################
###                        Client                       ###
###########################################################
nacl = require("ecma-nacl")
ServerSecretKey = new Uint8Array([196, 192, 198, 29, 168, 5, 49, 132, 10, 116, 101, 128, 155, 27, 56, 194, 38, 114, 50, 82, 236, 181, 84, 70, 146, 48, 110, 117, 95, 165, 46, 76])
ServerPublicKey = nacl.box.generate_pubkey ServerSecretKey

Login = (athlete) ->
  return if not athlete
  athletePublicKey = new Uint8Array( athlete.publicKey )

  _encryptor = null
  Encrypt = (message) ->
    message_string = JSON.stringify message
    message_bytes  = new Uint8Array( new Buffer( message_string ) )
    message_cipher = _encryptor.pack message_bytes
    return _.flatten message_cipher

  _decryptor = nacl.box.formatWN.makeDecryptor athletePublicKey, ServerSecretKey
  Decrypt = (received_cipher) ->
    received_cipher = new Uint8Array( received_cipher )
    if not _encryptor?
      nonce = nacl.box.formatWN.copyNonceFrom received_cipher
      nacl.nonce.advanceOddly nonce
      arrFactory = nacl.arrays.makeFactory()
      _encryptor = nacl.box.formatWN.makeEncryptor athletePublicKey, ServerSecretKey, nonce

    message_bytes  = _decryptor.open received_cipher
    message_string = String.fromCharCode.apply null, message_bytes
    return message = JSON.parse message_string

  PubNub.unsubscribe {
    channel : athlete.channel
  }

  PubNub.subscribe {
    channel  : athlete.channel
    callback : (message) ->
      message = Decrypt message
      console.log 'Athlete Message: ', message

      switch message.action

        #------------------------------------------
        when 'AthleteService : Set Athlete'
          AlphaDB.get message.data._id, (e, official) ->
            official.height = message.data.height
            official.weight = message.data.weight
            official.bodyFat = message.data.bodyFat
            official.ffmiOffset = message.data.ffmiOffset
            official.favorites = message.data.favorites
            official.stars = message.data.stars
            official.secretKey = message.data.secretKey
            
            AlphaDB.insert official, official._id, (e, data) ->
              PubNub.publish {
                channel : athlete.channel
                message : Encrypt {
                  action : 'AthleteService : Set Athlete Complete'
                  data   : data
                }
              }

        #------------------------------------------
        when 'AthleteService : New Invitation'
          message.data._id = 'invitation_' + Date.now().toString(36).toUpperCase()
          message.data.uses = 1
          message.data.created = new Date()
          AlphaDB.insert  message.data, message.data._id, (e, data) ->
            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'AthleteService : Invitation Generated'
                data   : message.data
              }
            }

        #------------------------------------------
        when 'AthleteService : Check Invitation'
          AlphaDB.head 'invitation_' + message.data, (e, data) ->
            console.log 'e: ', e
            console.log 'data: ', data
            if e?
              PubNub.publish {
                channel : athlete.channel
                message : Encrypt {
                  action : 'AthleteService : Invitation Is Invalid'
                  data   : message.data
                }
              }
            else
              PubNub.publish {
                channel : athlete.channel
                message : Encrypt {
                  action : 'AthleteService : Invitation Is Valid'
                  data   : message.data
                }
              }

        #------------------------------------------
        when 'ProtocolService : New Protocol'
          message.data._id = 'protocol_' + Date.now().toString(36).toUpperCase()
          PubNub.publish {
            channel : athlete.channel
            message : Encrypt {
              action : 'ProtocolService : New Protocol Complete'
              data   : message.data
            }
          }

        #------------------------------------------
        when 'ProtocolService : Get Protocol'
          AlphaDB.get message.data._id, (e, data) ->
            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'ProtocolService : Update Protocol'
                data   : data
              }
            }

        #------------------------------------------
        when 'ProtocolService : Set Protocol'
          AlphaDB.insert message.data, message.data._id, (e, data) ->
            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'ProtocolService : Set Protocol Complete'
                data   : data
              }
            }

        #------------------------------------------
        when 'ProtocolService : Delete Protocol'
          return if not message.data?
          message.data.owner = 'deleted'
          AlphaDB.insert message.data, message.data._id, (e, data) ->

            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'ProtocolService : Delete Protocol Complete'
                data   : data
              }
            }

        #------------------------------------------
        when 'ProtocolService : Search'
          AlphaDB.search 'alpha_indexes', 'protocols', message.data, (e, data) ->
            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'ProtocolService : Search Results'
                data   : data
              }
            }

        #------------------------------------------
        when 'ProtocolService : Get Stats'
          AlphaDB.get 'stats_' + message.data._id, (e, data) ->
            if e? then data = {
              protocol : message.data._id
              stars : 0
              athletes : 0
              orders : 0
            }

            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'ProtocolService : Update Stats'
                data   : data
              }
            }

        #------------------------------------------
        when 'ProtocolService : Set Stats'
          AlphaDB.get 'stats_' + message.data._id, (e, data) ->
            if e? then data = {
              protocol : message.data._id
              stars : 0
              athletes : 0
              orders : 0
            }

            data.stars = data.stars - message.data.previous
            data.stars = data.stars + message.data.current
            data.athletes += 1 if message.data.previous is 0

            AlphaDB.insert data, 'stats_' + message.data._id, ->

        #------------------------------------------
        when 'OrderService : Verify Referral Code'
          AlphaDB.view 'alpha_indexes', 'referralCodes', { keys: [ message.data ] } , (e, data) ->
            if data.rows.length is 0
              PubNub.publish {
                channel : athlete.channel
                message : Encrypt {
                  action : 'OrderService : Referral Code Is Invalid'
                  data   : message.data
                }
              }
            else
              PubNub.publish {
                channel : athlete.channel
                message : Encrypt {
                  action : 'OrderService : Referral Code Is Valid'
                  data   : message.data
                }
              }
            
        #------------------------------------------
        when 'OrderService : Place Order'
          AlphaDB.insert message.data, message.data._id, (e, data) ->
            hangouts.sendchatmessage 'UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'OrderService : Place Order : ' + message.data._id ]]
            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'OrderService : Order Placed'
                data   : data
              }
            }

            for id, item of message.data.cart
              AlphaDB.get 'stats_' + id, (e, data) ->
                if e? then data = {
                  protocol : id
                  stars : 0
                  athletes : 0
                  orders : 0
                }
                data.orders += item.qty
                AlphaDB.insert data, 'stats_' + id, ->

        #------------------------------------------
        when 'OrderService : Get Order List'
          AlphaDB.view 'alpha_indexes', 'ordersByAthlete', { keys: [ message.data._id ] } , (e, data) ->
            if data?
              PubNub.publish {
                channel : athlete.channel
                message : Encrypt {
                  action : 'OrderService : Update Order List'
                  data   : data.rows
                }
            }

        #------------------------------------------
        when 'OrderService : Get Order'
          AlphaDB.get message.data, (e, data) ->
            delete data.fulfillment.tracking
            PubNub.publish {
              channel : athlete.channel
              message : Encrypt {
                action : 'OrderService : Update Order'
                data   : data
              }
            }

        #------------------------------------------
        when 'OrderService : Get Tracking Info'
          AlphaDB.get message.data, (e, data) ->
            getTrackingInfo data, (info) ->
              PubNub.publish {
                channel : athlete.channel
                message : Encrypt {
                  action : 'OrderService : Update Tracking Info'
                  data   : {
                    id : message.data
                    trackingInfo : info
                  }
                }
              }
    connect  : ->
      delete athlete.BTCPrivate
      PubNub.publish {
        channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
        message : {
          action : 'AthleteService : Update Athlete'
          data   : athlete
        }
      }
  }


###########################################################
###                       Server                        ###
###########################################################
PubNub.subscribe {
  channel  : '8e04b18a-f27f-430e-a772-6f91c5302caS'
  callback : (message) ->
    hangouts.sendchatmessage 'UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'Message from ' + message.sender + ': ' + message.text ]]
}
      

PubNub.subscribe {
  channel  : '8e04b18a-f27f-430e-a772-6f91c5302ca'
  callback : (message) ->
    console.log 'Server Message: ', message
    switch message.action

      #------------------------------------------
      when 'AthleteService : Get Athlete'
        AlphaDB.get message.data._id, (e, data) ->
          console.log 'Get Athlete error: ', e if e?
          Login data

      #------------------------------------------
      when 'Server : Status'
        PubNub.publish {
          channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
          message : {
            action : 'Server : Online'
            data   : JSON.parse(JSON.stringify(_.flatten( ServerPublicKey )))
          }
        }

      #------------------------------------------
      when 'Server : Get BTCrate'
        PubNub.publish {
          channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
          message : {
            action : 'BTCService : Update BTCrate'
            data   : CoinBaseData
          }
        }

      #------------------------------------------
      when 'AthleteService : Check Athlete ID'
        AlphaDB.head 'athlete_' + message.data, (e, data) ->
          console.log 'e: ', e
          console.log 'data: ', data
          if e?
            PubNub.publish {
              channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
              message : {
                action : 'AthleteService : Athlete ID Available'
                data   : message.data
              }
            }
          else
            PubNub.publish {
              channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
              message : {
                action : 'AthleteService : Athlete ID Unavailable'
                data   : message.data
              }
            }

      #------------------------------------------
      when 'AthleteService : New Athlete'
        newAthlete = message.data
        AlphaDB.head newAthlete._id, (e, data) ->
          if e?
            AlphaDB.head 'invitation_' + newAthlete.invitation, (e, data) ->
              if not e?
                AlphaDB.get 'invitation_' + newAthlete.invitation, (e, invitation) ->
                  invitation.uses -= 1
                  invitation._deleted = true if invitation.uses is 0
                  AlphaDB.insert invitation, invitation._id, ->

                  newAthlete.BTCPrivate = new bitcore.PrivateKey().toWIF()
                  newAthlete.BTCAddress = bitcore.PrivateKey.fromWIF(newAthlete.BTCPrivate).toAddress().toString()
                  newAthlete.accountCredit = 0
                  newAthlete.referralCode = Date.now().toString(36).toUpperCase()
                  newAthlete.channel = PubNub.uuid()
                  newAthlete.referer = invitation.athlete
                  delete newAthlete.invitation

                  AlphaDB.insert newAthlete, newAthlete._id, (e, data) ->
                    AlphaDB.get newAthlete._id, (e, data) ->
                      delete data.BTCPrivate
                      hangouts.sendchatmessage 'UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'AthleteService : New Athlete : ' + newAthlete._id ]]
                      PubNub.publish {
                        channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
                        message : {
                          action : 'AthleteService : Update Athlete'
                          data   : data
                        }
                      }
              else
                PubNub.publish {
                  channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
                  message : {
                    action : 'AthleteService : Invitation Is Invalid'
                    data   : message.data
                  }
                }
          else
            PubNub.publish {
              channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
              message : {
                action : 'AthleteService : Athlete ID Unavailable'
                data   : newAthlete._id.substring(8)
              }
            }

      #------------------------------------------
      when 'OrderService : Get Processing Time'
        PubNub.publish {
          channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
          message : {
            action : 'OrderService : Update Processing Time'
            data   : '7 Days'
          }
        }
  connect  : ->
    PubNub.publish {
      channel : '8e04b18a-f27f-430e-a772-6f91c5302ca'
      message : {
        action : 'Server : Online'
        data   : JSON.parse(JSON.stringify(_.flatten( ServerPublicKey )))
      }
    }
}
