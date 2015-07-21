'use strict'
#if window.location.protocol != "https:" then window.location.href = "https:" + window.location.href.substring(window.location.protocol.length)
app = angular.module 'lab', ['Login', 'NewMember', 'PubNubService', 'BTCService', 'OrderService', 'Order', 'AthleteService', 'Athlete', 'Messages', 'ProtocolService', 'Protocol', 'StatusBar', 'PrimaryMenu', 'Masthead', 'ShoppingCart', 'Search', 'ProtocolByID', 'Editor']

###########################################################
###                      Controllers                    ###
###########################################################

###########################################################
###                      Directives                     ###
###########################################################
