'use strict'
CompoundService = angular.module 'CompoundService', []

###########################################################
###                        Service                      ###
###########################################################

index = {
  ### -------------------------------------------------------
  'C-01AS' : {
    id                     : 'C-01BS'
    color                  : 'rgba(27, 154, 247, 1)' # Blue
    name                   : 'Testosterone Propionate'
    alias                  : ''
    mode                   : 'Injection'
    price                  : 0.017
    density                : 300
    bioavailability        : 0.80
    halfLife               : 0.8
    ffmiStandard           : 50
    ffmiInterval           : 1
    androgenReceptor       : 0.1998
    progesteroneReceptor   : 0
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }
  ###
  # -------------------------------------------------------
  'C-01AS' : {
    id                     : 'C-01AS'
    color                  : 'rgba(27, 154, 247, 1)' # Blue
    name                   : 'Testosterone Acetate'
    alias                  : ''
    mode                   : 'Injection'
    price                  : 0.021
    density                : 300
    bioavailability        : 0.87
    halfLife               : 1
    ffmiStandard           : 50
    ffmiInterval           : 1
    androgenReceptor       : 0.1998
    progesteroneReceptor   : 0
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-01CL' : {
    id                     : 'C-01CL'
    color                  : 'rgba(123, 114, 233, 1)' # Blue/Purple
    name                   : 'Testosterone Cypionate'
    alias                  : ''
    mode                   : 'Injection'
    price                  : 0.014
    density                : 500
    bioavailability        : 0.69
    halfLife               : 5
    ffmiStandard           : 37
    ffmiInterval           : 3
    androgenReceptor       : 0.1998
    progesteroneReceptor   : 0
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-01DL' : {
    id                     : 'C-01DL'
    color                  : 'rgba(216, 80, 214, 1)' # Fuchsia
    name                   : 'Testosterone Enanthate'
    alias                  : ''
    mode                   : 'Injection'
    price                  : 0.014
    density                : 500
    bioavailability        : 0.70
    halfLife               : 4.5
    ffmiStandard           : 37
    ffmiInterval           : 3
    androgenReceptor       : 0.1998
    progesteroneReceptor   : 0
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-02AS' : {
    id                     : 'C-02AS'
    color                  : 'rgba(255, 67, 81, 1)' # Red
    name                   : 'Trenbolone Acetate'
    alias                  : 'Finaplix H'
    mode                   : 'Injection'
    price                  : 0.052
    density                : 300
    bioavailability        : 0.87
    halfLife               : 1
    ffmiStandard           : 50
    ffmiInterval           : 1
    androgenReceptor       : 0.9434
    progesteroneReceptor   : 0.0261
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-02BL' : {
    id                     : 'C-02BL'
    color                  : 'rgba(250, 103, 59, 1)' # Red/Orange
    name                   : 'Trenbolone Enanthate'
    alias                  : ''
    mode                   : 'Injection'
    price                  : 0.028
    density                : 500
    bioavailability        : 0.7
    halfLife               : 4.5
    ffmiStandard           : 22
    ffmiInterval           : 3
    androgenReceptor       : 0.9434
    progesteroneReceptor   : 0.0261
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-03AS' : {
    id                     : 'C-03AS'
    color                  : 'rgba(254, 211, 62, 1)' # Yellow
    name                   : 'Drostanolone Propionate'
    alias                  : 'Masteron'
    mode                   : 'Injection'
    price                  : 0.052
    density                : 300
    bioavailability        : 0.8
    halfLife               : 0.8
    ffmiStandard           : 50
    ffmiInterval           : 1
    androgenReceptor       : 0.3320
    progesteroneReceptor   : 0
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-03BL' : {
    id                     : 'C-03BL'
    color                  : 'rgba(250, 136, 41, 1)' # Orange
    name                   : 'Drostanolone Enanthate'
    alias                  : 'Masteron'
    mode                   : 'Injection'
    price                  : 0.052
    density                : 300
    bioavailability        : 0.8
    halfLife               : 0.8
    ffmiStandard           : 50
    ffmiInterval           : 1
    androgenReceptor       : 0.3320
    progesteroneReceptor   : 0
    estrogenAlphaReceptor  : 0
    estrogenBetaReceptor   : 0
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-04BL' : {
    id                     : 'C-04BL'
    color                  : 'rgba(81, 230, 80, 1)' # Green
    name                   : 'Nandrolone Decanoate'
    alias                  : ''
    mode                   : 'Injection'
    price                  : 0.021
    density                : 400
    bioavailability        : 0.64
    halfLife               : 7.5
    ffmiStandard           : 55
    ffmiInterval           : 3
    androgenReceptor       : 0.6987
    progesteroneReceptor   : 0.005
    estrogenAlphaReceptor  : 0.0001
    estrogenBetaReceptor   : 0.0002
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------
  'C-05BL' : {
    id                     : 'C-05BL'
    color                  : 'rgba(85, 218, 225, 1)' # Green/Blue 'rgba(235, 74, 149, 1)' # Fuchsia/Red
    name                   : 'Boldenone Undecylenate'
    alias                  : 'Equipoise'
    mode                   : 'Injection'
    price                  : 0.013
    density                : 600
    bioavailability        : 0.61
    halfLife               : 14
    ffmiStandard           : 60
    ffmiInterval           : 3
    androgenReceptor       : 0.6987
    progesteroneReceptor   : 0.005
    estrogenAlphaReceptor  : 0.0001
    estrogenBetaReceptor   : 0.0002
    glucocorticoidReceptor : 0
  }

  # -------------------------------------------------------

}
displayList = [
  index['C-02AS'] # Red
  index['C-02BL'] # Red/Orange
  index['C-03BL'] # Orange
  index['C-03AS'] # Yellow
  index['C-04BL'] # Green
  index['C-05BL'] # Green/Blue
  #index['C-01BS'] # Green/Blue
  index['C-01AS'] # Blue
  index['C-01CL'] # Blue/Fuchsia
  index['C-01DL'] # Fuchsia

]
CompoundService.factory 'Compounds', ->
  return (id) ->
    if id?
      return index[id] if id isnt 'list'
      return displayList if id is 'list'
    else
      return index
