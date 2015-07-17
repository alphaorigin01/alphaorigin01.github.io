// Generated by CoffeeScript 1.9.2
(function() {
  'use strict';
  var CompoundService, displayList, index;

  CompoundService = angular.module('CompoundService', []);


  /*                        Service */

  index = {

    /* -------------------------------------------------------
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
     */
    'C-01AS': {
      id: 'C-01AS',
      color: 'rgba(27, 154, 247, 1)',
      name: 'Testosterone Acetate',
      alias: '',
      mode: 'Injection',
      price: 0.021,
      density: 300,
      bioavailability: 0.87,
      halfLife: 1,
      ffmiStandard: 50,
      ffmiInterval: 1,
      androgenReceptor: 0.1998,
      progesteroneReceptor: 0,
      estrogenAlphaReceptor: 0,
      estrogenBetaReceptor: 0,
      glucocorticoidReceptor: 0
    },
    'C-01CL': {
      id: 'C-01CL',
      color: 'rgba(123, 114, 233, 1)',
      name: 'Testosterone Cypionate',
      alias: '',
      mode: 'Injection',
      price: 0.014,
      density: 500,
      bioavailability: 0.69,
      halfLife: 5,
      ffmiStandard: 37,
      ffmiInterval: 3,
      androgenReceptor: 0.1998,
      progesteroneReceptor: 0,
      estrogenAlphaReceptor: 0,
      estrogenBetaReceptor: 0,
      glucocorticoidReceptor: 0
    },
    'C-01DL': {
      id: 'C-01DL',
      color: 'rgba(216, 80, 214, 1)',
      name: 'Testosterone Enanthate',
      alias: '',
      mode: 'Injection',
      price: 0.014,
      density: 500,
      bioavailability: 0.70,
      halfLife: 4.5,
      ffmiStandard: 37,
      ffmiInterval: 3,
      androgenReceptor: 0.1998,
      progesteroneReceptor: 0,
      estrogenAlphaReceptor: 0,
      estrogenBetaReceptor: 0,
      glucocorticoidReceptor: 0
    },
    'C-02AS': {
      id: 'C-02AS',
      color: 'rgba(255, 67, 81, 1)',
      name: 'Trenbolone Acetate',
      alias: 'Finaplix H',
      mode: 'Injection',
      price: 0.052,
      density: 300,
      bioavailability: 0.87,
      halfLife: 1,
      ffmiStandard: 50,
      ffmiInterval: 1,
      androgenReceptor: 0.9434,
      progesteroneReceptor: 0.0261,
      estrogenAlphaReceptor: 0,
      estrogenBetaReceptor: 0,
      glucocorticoidReceptor: 0
    },
    'C-02BL': {
      id: 'C-02BL',
      color: 'rgba(250, 103, 59, 1)',
      name: 'Trenbolone Enanthate',
      alias: '',
      mode: 'Injection',
      price: 0.028,
      density: 500,
      bioavailability: 0.7,
      halfLife: 4.5,
      ffmiStandard: 22,
      ffmiInterval: 3,
      androgenReceptor: 0.9434,
      progesteroneReceptor: 0.0261,
      estrogenAlphaReceptor: 0,
      estrogenBetaReceptor: 0,
      glucocorticoidReceptor: 0
    },
    'C-03AS': {
      id: 'C-03AS',
      color: 'rgba(254, 211, 62, 1)',
      name: 'Drostanolone Propionate',
      alias: 'Masteron',
      mode: 'Injection',
      price: 0.052,
      density: 300,
      bioavailability: 0.8,
      halfLife: 0.8,
      ffmiStandard: 50,
      ffmiInterval: 1,
      androgenReceptor: 0.3320,
      progesteroneReceptor: 0,
      estrogenAlphaReceptor: 0,
      estrogenBetaReceptor: 0,
      glucocorticoidReceptor: 0
    },
    'C-03BL': {
      id: 'C-03BL',
      color: 'rgba(250, 136, 41, 1)',
      name: 'Drostanolone Enanthate',
      alias: 'Masteron',
      mode: 'Injection',
      price: 0.052,
      density: 300,
      bioavailability: 0.8,
      halfLife: 0.8,
      ffmiStandard: 50,
      ffmiInterval: 1,
      androgenReceptor: 0.3320,
      progesteroneReceptor: 0,
      estrogenAlphaReceptor: 0,
      estrogenBetaReceptor: 0,
      glucocorticoidReceptor: 0
    },
    'C-04BL': {
      id: 'C-04BL',
      color: 'rgba(81, 230, 80, 1)',
      name: 'Nandrolone Decanoate',
      alias: '',
      mode: 'Injection',
      price: 0.021,
      density: 400,
      bioavailability: 0.64,
      halfLife: 7.5,
      ffmiStandard: 55,
      ffmiInterval: 3,
      androgenReceptor: 0.6987,
      progesteroneReceptor: 0.005,
      estrogenAlphaReceptor: 0.0001,
      estrogenBetaReceptor: 0.0002,
      glucocorticoidReceptor: 0
    },
    'C-05BL': {
      id: 'C-05BL',
      color: 'rgba(85, 218, 225, 1)',
      name: 'Boldenone Undecylenate',
      alias: 'Equipoise',
      mode: 'Injection',
      price: 0.013,
      density: 600,
      bioavailability: 0.61,
      halfLife: 14,
      ffmiStandard: 60,
      ffmiInterval: 3,
      androgenReceptor: 0.6987,
      progesteroneReceptor: 0.005,
      estrogenAlphaReceptor: 0.0001,
      estrogenBetaReceptor: 0.0002,
      glucocorticoidReceptor: 0
    }
  };

  displayList = [index['C-02AS'], index['C-02BL'], index['C-03BL'], index['C-03AS'], index['C-04BL'], index['C-05BL'], index['C-01AS'], index['C-01CL'], index['C-01DL']];

  CompoundService.factory('Compounds', function() {
    return function(id) {
      if (id != null) {
        if (id !== 'list') {
          return index[id];
        }
        if (id === 'list') {
          return displayList;
        }
      } else {
        return index;
      }
    };
  });

}).call(this);
