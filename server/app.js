// Generated by CoffeeScript 1.9.2
(function() {
  var AlphaDB, Client, Cloudant, CoinBaseData, Login, PubNub, Q, ServerPublicKey, ServerSecretKey, UpdateCloudant, UpdateCoinBaseData, _, bitcore, cheerio, creds, getTrackingInfo, hangouts, nacl, pubnubBroadcastConfig, reconnect, request;

  _ = require('lodash');


  /*                       Tracking */

  cheerio = require("cheerio");

  getTrackingInfo = function(order, cb) {
    if (order.fulfillment.tracking !== '') {
      return request('https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=' + order.fulfillment.tracking, function(error, response, body) {
        var $, trackingInfo;
        trackingInfo = {
          history: []
        };
        $ = cheerio.load(body, {
          normalizeWhitespace: true
        });
        trackingInfo.deliveryDay = $('div.tracking-progress span.value:nth-child(2)').text();
        $('.detail-wrapper').each(function() {
          return trackingInfo.history.push({
            date: $(this).find('.date-time').text(),
            status: $(this).find('.status').text()
          });
        });
        return cb(trackingInfo);
      });
    }
  };


  /*                        PubNub */

  pubnubBroadcastConfig = {
    origin: 'rebtelsdk.pubnub.com',
    ssl: true,
    publish_key: 'pub-c-0ad3b937-16a4-4563-819a-d9c108daf8a1',
    subscribe_key: 'sub-c-cf1ec346-a876-11e2-80da-12313f022c90',
    cipher_key: 'sample',
    uuid: '8e04b18a-f27f-430e-a772-6f91c5302ca'
  };

  PubNub = require("pubnub")(pubnubBroadcastConfig);


  /*                        Bitcore */

  bitcore = require("bitcore");


  /*                       Hangups */

  Client = require('hangupsjs');

  Q = require('q');

  creds = function() {
    return {
      auth: Client.authStdin
    };
  };

  hangouts = new Client();

  hangouts.on('chat_message', function(msg) {
    var parse;
    console.log('======> Hangouts Message: ', msg);
    parse = msg.chat_message.message_content.segment[0].text.split(':: ');
    if (parse.length === 2) {
      return AlphaDB.get('athlete_' + parse[0], function(e, athlete) {
        if (e != null) {
          return hangouts.sendchatmessage('UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'Message error.']]);
        } else {
          return PubNub.publish({
            channel: athlete.channel + 'S',
            message: {
              sender: 'athlete_Alpha',
              text: parse[1]
            }
          });
        }
      });
    }
  });

  hangouts.on('connected', function() {
    return hangouts.setactiveclient(true, 1000);
  });

  (reconnect = function() {
    return hangouts.connect(creds);
  })();

  hangouts.on('connect_failed', function() {
    return setTimeout(reconnect, 3000);
  });


  /*                       CoinBase */

  request = require("request");

  CoinBaseData = {};

  (UpdateCoinBaseData = function() {
    return request('https://api.coinbase.com/v1/prices/sell?qty=1', function(error, response, body) {
      try {
        CoinBaseData = JSON.parse(body);
      } catch (_error) {}
      return console.log('CoinBaseData: ', CoinBaseData);
    });
  })();

  setInterval(UpdateCoinBaseData, 300000);


  /*                       Cloudant */

  Cloudant = require('nano')('https://timothyjoelwright.cloudant.com');

  AlphaDB = null;

  (UpdateCloudant = function() {
    return Cloudant.auth('timothyjoelwright', 'BfIQ6JX3CAfBmCx', function(err, response, headers) {
      var cookie;
      try {
        cookie = headers['set-cookie'];
      } catch (_error) {}
      console.log('cookie: ', cookie);
      Cloudant = require('nano')({
        url: 'https://timothyjoelwright.cloudant.com',
        cookie: cookie
      });
      return AlphaDB = Cloudant.use('alpha');
    });
  })();

  setInterval(UpdateCloudant, 3600000);


  /*                        Client */

  nacl = require("ecma-nacl");

  ServerSecretKey = new Uint8Array([196, 192, 198, 29, 168, 5, 49, 132, 10, 116, 101, 128, 155, 27, 56, 194, 38, 114, 50, 82, 236, 181, 84, 70, 146, 48, 110, 117, 95, 165, 46, 76]);

  ServerPublicKey = nacl.box.generate_pubkey(ServerSecretKey);

  Login = function(athlete) {
    var Decrypt, Encrypt, _decryptor, _encryptor, athletePublicKey;
    if (!athlete) {
      return;
    }
    athletePublicKey = new Uint8Array(athlete.publicKey);
    _encryptor = null;
    Encrypt = function(message) {
      var message_bytes, message_cipher, message_string;
      message_string = JSON.stringify(message);
      message_bytes = new Uint8Array(new Buffer(message_string));
      message_cipher = _encryptor.pack(message_bytes);
      return _.flatten(message_cipher);
    };
    _decryptor = nacl.box.formatWN.makeDecryptor(athletePublicKey, ServerSecretKey);
    Decrypt = function(received_cipher) {
      var arrFactory, message, message_bytes, message_string, nonce;
      received_cipher = new Uint8Array(received_cipher);
      if (_encryptor == null) {
        nonce = nacl.box.formatWN.copyNonceFrom(received_cipher);
        nacl.nonce.advanceOddly(nonce);
        arrFactory = nacl.arrays.makeFactory();
        _encryptor = nacl.box.formatWN.makeEncryptor(athletePublicKey, ServerSecretKey, nonce);
      }
      message_bytes = _decryptor.open(received_cipher);
      message_string = String.fromCharCode.apply(null, message_bytes);
      return message = JSON.parse(message_string);
    };
    PubNub.unsubscribe({
      channel: athlete.channel
    });
    return PubNub.subscribe({
      channel: athlete.channel,
      callback: function(message) {
        message = Decrypt(message);
        console.log('Athlete Message: ', message);
        switch (message.action) {
          case 'AthleteService : Set Athlete':
            return AlphaDB.get(message.data._id, function(e, official) {
              official.height = message.data.height;
              official.weight = message.data.weight;
              official.bodyFat = message.data.bodyFat;
              official.ffmiOffset = message.data.ffmiOffset;
              official.favorites = message.data.favorites;
              official.stars = message.data.stars;
              official.secretKey = message.data.secretKey;
              return AlphaDB.insert(official, official._id, function(e, data) {
                return PubNub.publish({
                  channel: athlete.channel,
                  message: Encrypt({
                    action: 'AthleteService : Set Athlete Complete',
                    data: data
                  })
                });
              });
            });
          case 'AthleteService : New Invitation':
            message.data._id = 'invitation_' + Date.now().toString(36).toUpperCase();
            message.data.uses = 1;
            message.data.created = new Date();
            return AlphaDB.insert(message.data, message.data._id, function(e, data) {
              return PubNub.publish({
                channel: athlete.channel,
                message: Encrypt({
                  action: 'AthleteService : Invitation Generated',
                  data: message.data
                })
              });
            });
          case 'ProtocolService : New Protocol':
            message.data._id = 'protocol_' + Date.now().toString(36).toUpperCase();
            return PubNub.publish({
              channel: athlete.channel,
              message: Encrypt({
                action: 'ProtocolService : New Protocol Complete',
                data: message.data
              })
            });
          case 'ProtocolService : Get Protocol':
            return AlphaDB.get(message.data._id, function(e, data) {
              return PubNub.publish({
                channel: athlete.channel,
                message: Encrypt({
                  action: 'ProtocolService : Update Protocol',
                  data: data
                })
              });
            });
          case 'ProtocolService : Set Protocol':
            return AlphaDB.insert(message.data, message.data._id, function(e, data) {
              return PubNub.publish({
                channel: athlete.channel,
                message: Encrypt({
                  action: 'ProtocolService : Set Protocol Complete',
                  data: data
                })
              });
            });
          case 'ProtocolService : Delete Protocol':
            if (message.data == null) {
              return;
            }
            message.data.owner = 'deleted';
            return AlphaDB.insert(message.data, message.data._id, function(e, data) {
              return PubNub.publish({
                channel: athlete.channel,
                message: Encrypt({
                  action: 'ProtocolService : Delete Protocol Complete',
                  data: data
                })
              });
            });
          case 'ProtocolService : Get Stats':
            return AlphaDB.get('stats_' + message.data._id, function(e, data) {
              if (e != null) {
                data = {
                  protocol: message.data._id,
                  stars: 0,
                  athletes: 0,
                  orders: 0
                };
              }
              return PubNub.publish({
                channel: athlete.channel,
                message: Encrypt({
                  action: 'ProtocolService : Update Stats',
                  data: data
                })
              });
            });
          case 'ProtocolService : Set Stats':
            return AlphaDB.get('stats_' + message.data._id, function(e, data) {
              if (e != null) {
                data = {
                  protocol: message.data._id,
                  stars: 0,
                  athletes: 0,
                  orders: 0
                };
              }
              data.stars = data.stars - message.data.previous;
              data.stars = data.stars + message.data.current;
              if (message.data.previous === 0) {
                data.athletes += 1;
              }
              return AlphaDB.insert(data, 'stats_' + message.data._id, function() {});
            });
          case 'OrderService : Verify Referral Code':
            return AlphaDB.view('alpha_indexes', 'referralCodes', {
              keys: [message.data]
            }, function(e, data) {
              if (data.rows.length === 0) {
                return PubNub.publish({
                  channel: athlete.channel,
                  message: Encrypt({
                    action: 'OrderService : Referral Code Is Invalid',
                    data: message.data
                  })
                });
              } else {
                return PubNub.publish({
                  channel: athlete.channel,
                  message: Encrypt({
                    action: 'OrderService : Referral Code Is Valid',
                    data: message.data
                  })
                });
              }
            });
          case 'OrderService : Place Order':
            return AlphaDB.insert(message.data, message.data._id, function(e, data) {
              var id, item, ref, results;
              hangouts.sendchatmessage('UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'OrderService : Place Order : ' + message.data._id]]);
              PubNub.publish({
                channel: athlete.channel,
                message: Encrypt({
                  action: 'OrderService : Order Placed',
                  data: data
                })
              });
              ref = message.data.cart;
              results = [];
              for (id in ref) {
                item = ref[id];
                results.push(AlphaDB.get('stats_' + id, function(e, data) {
                  if (e != null) {
                    data = {
                      protocol: id,
                      stars: 0,
                      athletes: 0,
                      orders: 0
                    };
                  }
                  data.orders += item.qty;
                  return AlphaDB.insert(data, 'stats_' + id, function() {});
                }));
              }
              return results;
            });
          case 'OrderService : Get Order List':
            return AlphaDB.view('alpha_indexes', 'ordersByAthlete', {
              keys: [message.data._id]
            }, function(e, data) {
              if (data != null) {
                return PubNub.publish({
                  channel: athlete.channel,
                  message: Encrypt({
                    action: 'OrderService : Update Order List',
                    data: data.rows
                  })
                });
              }
            });
          case 'OrderService : Get Order':
            return AlphaDB.get(message.data, function(e, data) {
              delete data.fulfillment.tracking;
              return PubNub.publish({
                channel: athlete.channel,
                message: Encrypt({
                  action: 'OrderService : Update Order',
                  data: data
                })
              });
            });
          case 'OrderService : Get Tracking Info':
            return AlphaDB.get(message.data, function(e, data) {
              return getTrackingInfo(data, function(info) {
                return PubNub.publish({
                  channel: athlete.channel,
                  message: Encrypt({
                    action: 'OrderService : Update Tracking Info',
                    data: {
                      id: message.data,
                      trackingInfo: info
                    }
                  })
                });
              });
            });
        }
      },
      connect: function() {
        delete athlete.BTCPrivate;
        return PubNub.publish({
          channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
          message: {
            action: 'AthleteService : Update Athlete',
            data: athlete
          }
        });
      }
    });
  };


  /*                       Server */

  PubNub.subscribe({
    channel: '8e04b18a-f27f-430e-a772-6f91c5302caS',
    callback: function(message) {
      return hangouts.sendchatmessage('UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'Message from ' + message.sender + ': ' + message.text]]);
    }
  });

  PubNub.subscribe({
    channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
    callback: function(message) {
      var newAthlete;
      console.log('Server Message: ', message);
      switch (message.action) {
        case 'AthleteService : Get Athlete':
          return AlphaDB.get(message.data._id, function(e, data) {
            if (e != null) {
              console.log('Get Athlete error: ', e);
            }
            return Login(data);
          });
        case 'Server : Status':
          return PubNub.publish({
            channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
            message: {
              action: 'Server : Online',
              data: JSON.parse(JSON.stringify(_.flatten(ServerPublicKey)))
            }
          });
        case 'Server : Get BTCrate':
          return PubNub.publish({
            channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
            message: {
              action: 'BTCService : Update BTCrate',
              data: CoinBaseData
            }
          });
        case 'AthleteService : Check Athlete ID':
          return AlphaDB.head('athlete_' + message.data, function(e, data) {
            console.log('e: ', e);
            console.log('data: ', data);
            if (e != null) {
              return PubNub.publish({
                channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
                message: {
                  action: 'AthleteService : Athlete ID Available',
                  data: message.data
                }
              });
            } else {
              return PubNub.publish({
                channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
                message: {
                  action: 'AthleteService : Athlete ID Unavailable',
                  data: message.data
                }
              });
            }
          });
        case 'AthleteService : Check Invitation':
          return AlphaDB.head('invitation_' + message.data, function(e, data) {
            console.log('e: ', e);
            console.log('data: ', data);
            if (e != null) {
              return PubNub.publish({
                channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
                message: {
                  action: 'AthleteService : Invitation Is Invalid',
                  data: message.data
                }
              });
            } else {
              return PubNub.publish({
                channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
                message: {
                  action: 'AthleteService : Invitation Is Valid',
                  data: message.data
                }
              });
            }
          });
        case 'AthleteService : New Athlete':
          newAthlete = message.data;
          return AlphaDB.head(newAthlete._id, function(e, data) {
            if (e != null) {
              return AlphaDB.head('invitation_' + newAthlete.invitation, function(e, data) {
                if (e == null) {
                  return AlphaDB.get('invitation_' + newAthlete.invitation, function(e, invitation) {
                    invitation.uses -= 1;
                    if (invitation.uses === 0) {
                      invitation._deleted = true;
                    }
                    AlphaDB.insert(invitation, invitation._id, function() {});
                    newAthlete.BTCPrivate = new bitcore.PrivateKey().toWIF();
                    newAthlete.BTCAddress = bitcore.PrivateKey.fromWIF(newAthlete.BTCPrivate).toAddress().toString();
                    newAthlete.accountCredit = 0;
                    newAthlete.referralCode = Date.now().toString(36).toUpperCase();
                    newAthlete.channel = PubNub.uuid();
                    newAthlete.referer = invitation.athlete;
                    delete newAthlete.invitation;
                    return AlphaDB.insert(newAthlete, newAthlete._id, function(e, data) {
                      return AlphaDB.get(newAthlete._id, function(e, data) {
                        delete data.BTCPrivate;
                        hangouts.sendchatmessage('UgxWbu3GrCCYsLSgQ_N4AaABAQ', [[0, 'AthleteService : New Athlete : ' + newAthlete._id]]);
                        return PubNub.publish({
                          channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
                          message: {
                            action: 'AthleteService : Update Athlete',
                            data: data
                          }
                        });
                      });
                    });
                  });
                } else {
                  return PubNub.publish({
                    channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
                    message: {
                      action: 'AthleteService : Invitation Is Invalid',
                      data: message.data
                    }
                  });
                }
              });
            } else {
              return PubNub.publish({
                channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
                message: {
                  action: 'AthleteService : Athlete ID Unavailable',
                  data: newAthlete._id.substring(8)
                }
              });
            }
          });
        case 'OrderService : Get Processing Time':
          return PubNub.publish({
            channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
            message: {
              action: 'OrderService : Update Processing Time',
              data: '7 Days'
            }
          });
        case 'ProtocolService : Search':
          return AlphaDB.search('alpha_indexes', 'protocols', message.data, function(e, data) {
            return PubNub.publish({
              channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
              message: {
                action: 'ProtocolService : Search Results',
                data: data
              }
            });
          });
      }
    },
    connect: function() {
      return PubNub.publish({
        channel: '8e04b18a-f27f-430e-a772-6f91c5302ca',
        message: {
          action: 'Server : Online',
          data: JSON.parse(JSON.stringify(_.flatten(ServerPublicKey)))
        }
      });
    }
  });

}).call(this);
