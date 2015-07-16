'use strict'
ProtocolService = angular.module 'ProtocolService', ['CompoundService', 'AthleteService', 'BTCService', 'PubNubService']

###########################################################
###                        Service                      ###
###########################################################

ProtocolService.factory 'Protocol', [ 'Compounds', 'Athlete', 'BTCrate', 'PubNub', '$http', '$rootScope', '$timeout', (Compounds, Athlete, BTCrate, PubNub, $http, $rootScope, $timeout) ->

  $rootScope.$on 'UpdateAthlete', (e, data) ->
    Athlete = data

  class Regimen
    constructor          : (_compoundId, _protocol) ->
      that = this
      save = -> do _protocol._save
      update = ->
        return if not that.compound?

        # levels
        levelsMinion = new Worker 'assets/js/Worker_CalculateLevels.js'
        levelsMinion.onmessage = (e) ->
          that.levels = e.data.levels
          that.dose = Math.ceil e.data.dose
          that.loadingDose = Math.ceil e.data.loadingDose
          that.variance = ( 1 - ( that.adjustedActiveTarget / e.data.max ) ) * 100

          # graph
          $rootScope.$evalAsync ->
            hour = ( that.startDay - 1 ) * 24

            addData = (element, index, list) ->
              data = { hour  :  hour + index }
              data[ _compoundId ] = Math.round(element)
              return data

            that.graphDataProvider = _.map that.levels, addData
            if that.graph?
              that.graph.dataProvider = that.graphDataProvider
              setTimeout -> that.graph.validateData()
              that.graph.zoomToIndexes 1, that.graph.dataProvider.length - 2

          # protocol
          do that.protocol._update

        adjustedActiveTarget = that.adjustedActiveTarget
        levelsMinion.postMessage {
          halfLife             : that.compound.halfLife
          bioavailability      : that.compound.bioavailability
          duration             : that.duration
          interval             : that.interval
          density              : that.density
          activeTarget         : adjustedActiveTarget
        }
      update = _.debounce update, 250

      #------------------------------------------
      hashkey = null
      Object.defineProperty this, '$$hashkey', {
        enumerable : false
        }

      #------------------------------------------
      protocol = _protocol
      Object.defineProperty this, 'protocol', {
        get        : -> return protocol
        set        : ->
        }

      #------------------------------------------
      compound = Compounds _compoundId
      Object.defineProperty this, 'compound', {
        enumerable : true
        get        : -> return compound
        set        : ->
        }

      #------------------------------------------
      activeTarget = compound.ffmiStandard
      Object.defineProperty this, 'activeTarget', {
        enumerable : true
        get        : -> return activeTarget
        set        : (x) ->
          if activeTarget isnt x
            activeTarget = x #Math.round(x / 5) * 5
            do save
            do update
        }

      #------------------------------------------
      density = compound.density / 2
      Object.defineProperty this, 'density', {
        enumerable : true
        get        : -> return density
        set        : (x) ->
          return density = compound.density if x > compound.density
          if density isnt x
            density = Math.round(x / 5) * 5
            do save
            do update
        }

      #------------------------------------------
      interval = compound.ffmiInterval
      Object.defineProperty this, 'interval', {
        enumerable : true
        get        : -> return interval
        set        : (x) ->
          if interval isnt x
            interval = Math.round(x)
            do save
            do update
        }

      #------------------------------------------
      startDay = 1
      Object.defineProperty this, 'startDay', {
        enumerable : true
        get        : -> return startDay
        set        : (x) ->
          if startDay isnt x
            startDay = Math.round(x)
            do save
            do update
        }

      #------------------------------------------
      duration = compound.ffmiInterval
      Object.defineProperty this, 'duration', {
        enumerable : true
        get        : -> return duration
        set        : (x) ->
          if duration isnt x
            x = Math.floor(140 / @interval) * @interval if x > 140
            duration = Math.round( x / @interval) * @interval
            do save
            do update
        }

      #------------------------------------------
      Object.defineProperty this, 'graphDataProvider', {
        enumerable : false
        writable   : true
      }

      #------------------------------------------
      graph = null
      Object.defineProperty this, 'graph', {
        get        : -> return graph
        set        : (x) ->
          graph = AmCharts.makeChart x[0], {
            'type': 'serial'
            'theme': 'none'
            'pathToImages': 'http://cdn.amcharts.com/lib/3/images/'
            'categoryField': 'hour'
            'autoMargins': false
            'marginBottom': 0
            'marginLeft': 0
            'marginRight': 0
            'marginTop': 0
            'borderAlpha': 0
            'chartCursor': {
              'selectWithoutZooming': true
              'zoomable': false
              'zooming': false
            }
            'zoomOutButtonImage': ''
            'zoomOutText': ''
            'graphs': [
              {
                'fillAlphas': 1
                'fillColors': @compound.color
                'id': 'AmGraph-1'
                'lineAlpha': 0
                'title': 'Rate of Compound Release'
                'type': 'line'
                'valueField': @compound.id
                'balloonFunction': (graphDataItem, graph) ->
                  day = Math.floor( parseInt(graphDataItem.category) / 24 ) + 1
                  hour = Math.floor( ( parseInt(graphDataItem.category) / 24 - day + 1 ) / ( 1 / 24 ) )
                  return graphDataItem.values.value + 'mg<br>Day: ' + day + ' Hour: ' + hour
              }
            ]
            'valueAxes': [
              {
                'id': 'ValueAxis-1',
                'title': 'Axis title'
                'axisAlpha': 0,
                'gridAlpha': 0,
              }
            ]
            'categoryAxis': {
              'axisAlpha': 0,
              'gridAlpha': 0,
              'minorGridAlpha': 0
            }
            'dataProvider': []
          }

          that = this
          $rootScope.$evalAsync ->
            that.graph.dataProvider = that.graphDataProvider
            setTimeout -> that.graph.validateData()
            that.graph.zoomToIndexes 1, that.graph.dataProvider.length - 2
        }

      #------------------------------------------
      levels = null
      Object.defineProperty this, 'levels', {
        get        : ->
          do update if not levels or levels.length is 0
          return levels
        set        : (x) -> levels = x
        }

      #------------------------------------------
      variance = 0
      Object.defineProperty this, 'variance', {
        get        : -> return variance
        set        : (x) -> variance = x
        }

      #------------------------------------------
      dose = 0
      Object.defineProperty this, 'dose', {
        get        : -> return dose
        set        : (x) -> dose = x
        }

      #------------------------------------------
      Object.defineProperty this, 'doseVolume', {
        get        : -> return ( @dose / density )
        set        : (x) ->
        }

      #------------------------------------------
      loadingDose = 0
      Object.defineProperty this, 'loadingDose', {
        get        : -> return loadingDose
        set        : (x) -> loadingDose = x
        }

      #------------------------------------------
      Object.defineProperty this, 'loadingVolume', {
        get        : -> return ( @loadingDose / density )
        set        : (x) ->
        }

      #------------------------------------------
      Object.defineProperty this, 'totalVolume', {
        get        : -> return ( @doseVolume * ( @duration / @interval ) ) + @loadingVolume
        set        : (x) ->
        }

      #------------------------------------------
      Object.defineProperty this, 'adjustedActiveTarget', {
        get        : -> return Math.round( @activeTarget * ( Athlete.ffmi / 25 ) ) #Math.round( ( @activeTarget * ( Athlete.ffmi / 25 ) ) / 5 ) * 5
        set        : (x) -> @activeTarget = Math.round parseFloat(x) * ( 25 / Athlete.ffmi )
        }


      do update
      do save


  class Protocol
    constructor          : ->
      that = this
      save = ->
        PubNub 'ProtocolService : Set Protocol', that if that.owner is Athlete._id and that.components.length > 0

      @_save = save = _.debounce save, 5000

      update = ->
        that.priceUSD = 0

        # formulations
        formulations = {}

        # Group identical forumlations together
        regimensByTime = _.groupBy that.components, (e) -> return e.startDay + ":" + e.interval + ":" + e.duration + ":" + e.compound.mode + ":" + e.dilution
        regimensByDose = _.groupBy _.values(regimensByTime), (e) ->
          id = ''
          for r in e
            id += r.compound.id + '[' + r.activeTarget + ']'
          return id

        # Create each formualtion object
        _.each _.values( regimensByDose ), (e, i) ->
          formulation = {
            id : String.fromCharCode(65 + i)
            schedules : []
            compounds : {}
            filler    : 0
            totalVolume : 0
          }

          # Create each schedule object in the formulation
          for s in e
            schedule = {
              startDay      : s[0].startDay
              interval      : s[0].interval
              duration      : s[0].duration
              doses         : s[0].duration / s[0].interval
              loadingVolume : 0
              doseVolume    : 0
              totalVolume   : 0
            }

            # Determine volumes of each component for the schedule
            for regimen in s

              # The total volume (compound + filler) of the component
              schedule.doseVolume += regimen.doseVolume
              schedule.loadingVolume += regimen.loadingVolume # includes initial dose as extra dose for anticipated losses

              # The total volume of the compound
              formulation.compounds[regimen.compound.id] = 0 if not formulation.compounds[ regimen.compoundId ]?
              formulation.compounds[regimen.compound.id] += regimen.totalVolume * ( regimen.density / regimen.compound.density )

              # The total volume of dilution filler for the desired density
              formulation.filler += regimen.totalVolume * ( 1 - ( regimen.density / regimen.compound.density ) )

              # Price for compound
              that.priceUSD += regimen.totalVolume * regimen.compound.density * regimen.compound.price * ( regimen.density / regimen.compound.density )


            # Calculate measurement filler needed for the mixed dose to be within 1/10th of a ml
            adjustedDoseVolume = Math.ceil( schedule.doseVolume * 10 ) /10
            adjustmentMultiplier = adjustedDoseVolume / schedule.doseVolume
            fillerPerDose = adjustedDoseVolume - schedule.doseVolume
            fillerPerVolume = fillerPerDose / schedule.doseVolume

            # Adjust dose and loading dose amounts for the additional measurement filler
            schedule.doseVolume = adjustedDoseVolume
            schedule.loadingVolume = Math.ceil( schedule.loadingVolume * adjustmentMultiplier * 10 ) /10

            # Determine total schedule volume
            schedule.totalVolume = schedule.loadingVolume + ( schedule.doseVolume * schedule.doses )
            formulation.totalVolume += schedule.totalVolume

            # Add the additional measurement filler to the formulation
            formulation.filler += schedule.totalVolume * fillerPerVolume

            # Add the completed schedule to the formulation
            formulation.schedules.push schedule

          # Add price for filler
          that.priceUSD += formulation.filler * 0.025
          # Add price for vials, stoppers, etc.
          that.priceUSD += Math.ceil( formulation.totalVolume / 30 ) * 2

          # Add the completed formulation to the protcol
          formulations[ formulation.id ] = formulation

        that.formulations = formulations



        # schedule
        schedule = []
        volume = []

        for i of that.formulations
          formulation = that.formulations[i]
          for s in formulation.schedules
            for day in [ s.startDay..s.duration ] by s.interval
              schedule[day] = [] if not schedule[day]?
              schedule[day].push formulation.id
              schedule[day] = _.uniq schedule[day]
              volume[day] = s.doseVolume

        that.schedule = schedule



        # price
        accessoriesQty = 0
        _.each volume, (v) ->
          return if not v?
          accessoriesQty += Math.ceil( v / 3 )

        that.accessoriesQty = accessoriesQty
        that.accessoriesPriceUSD = accessoriesQty * 0.2 # needles and alcohol pads
        that.accessoriesPriceUSD += 5 # shipping
        that.accessoriesPriceUSD += 2  # sharps container and misc.
        that.priceUSD += that.accessoriesPriceUSD * 2



        # graph
        $rootScope.$evalAsync ->
          if that.graph?
            that.graph.graphs = []

            compoundIds = []
            for regimen in that.components
              compoundIds.push regimen.compound.id

            for id in _.uniq compoundIds
              g = new AmCharts.AmGraph()
              g.fillAlphas = 1
              g.fillColors = Compounds(id).color
              g.lineAlpha = 0
              g.title = 'Rate of Compound Release'
              g.valueField = id
              g.balloonFunction = (graphDataItem, graph) ->
                day = Math.floor( parseInt(graphDataItem.category) / 24 ) + 1
                hour = Math.floor( ( parseInt(graphDataItem.category) / 24 - day + 1 ) / ( 1 / 24 ) )
                return graphDataItem.values.value + 'mg - Day: ' + day + ' Hour: ' + hour

              that.graph.addGraph g

            data = Array.apply(null, Array(260 * 24)).map Object
            for regimen in that.components
              _.each regimen.levels, (element, index, list) ->
                if not _.isNumber data[ ( ( regimen.startDay - 1 ) * 24 ) + index][ regimen.compoundId ] then data[ ( ( regimen.startDay - 1 ) * 24 ) + index][ regimen.compound.id ] = 0
                data[ ( ( regimen.startDay - 1 ) * 24 ) + index][ regimen.compound.id ] += Math.round(element)

            levels = Array.apply(null, Array(260 * 24)).map Object
            _.each data, (element, index, list) ->
              element.hour = index
              levels[ index ] = element

            _.remove levels, (n) -> ( Object.keys(n).length is 1 )

            that.graph.dataProvider = levels
            that.graph.validateData()

            $timeout -> do that._update if that.graph.chartData.length is 0

            # pharmacodynamics
            if that.pharmacodynamics?
              that.pharmacodynamics.graphs = []

              g = new AmCharts.AmGraph()
              g.fillColors = g.lineColor = 'rgba(255, 67, 81, 1)'
              g.title = 'Androgen Receptor Activity'
              g.valueField = 'androgen'
              g.type = 'smoothedLine'
              g.lineThickness = 1
              g.fillAlphas = 1
              g.balloonFunction = (graphDataItem, graph) ->
                day = Math.floor( parseInt(graphDataItem.category) / 24 ) + 1
                hour = Math.floor( ( parseInt(graphDataItem.category) / 24 - day + 1 ) / ( 1 / 24 ) )
                return graphDataItem.values.value + 'x - Day: ' + day + ' Hour: ' + hour

              that.pharmacodynamics.addGraph g

              g = new AmCharts.AmGraph()
              g.fillColors = g.lineColor = 'rgba(27, 154, 247, 1)' # blue
              g.title = 'Progesterone Receptor Activity'
              g.valueField = 'progesterone'
              g.type = 'smoothedLine'
              g.lineThickness = 1
              g.fillAlphas = 1
              g.balloonFunction = (graphDataItem, graph) ->
                day = Math.floor( parseInt(graphDataItem.category) / 24 ) + 1
                hour = Math.floor( ( parseInt(graphDataItem.category) / 24 - day + 1 ) / ( 1 / 24 ) )
                return graphDataItem.values.value + 'x - Day: ' + day + ' Hour: ' + hour

              that.pharmacodynamics.addGraph g

              g = new AmCharts.AmGraph()
              g.fillColors = g.lineColor = 'rgba(250, 136, 41, 1)' # orange
              g.title = 'Estrogen α Receptor Activity'
              g.valueField = 'estrogenAlpha'
              g.type = 'smoothedLine'
              g.lineThickness = 1
              g.fillAlphas = 1
              g.balloonFunction = (graphDataItem, graph) ->
                day = Math.floor( parseInt(graphDataItem.category) / 24 ) + 1
                hour = Math.floor( ( parseInt(graphDataItem.category) / 24 - day + 1 ) / ( 1 / 24 ) )
                return graphDataItem.values.value + 'x - Day: ' + day + ' Hour: ' + hour

              that.pharmacodynamics.addGraph g

              g = new AmCharts.AmGraph()
              g.fillColors = g.lineColor = 'rgba(254, 211, 62, 1)' # yellow
              g.title = 'Estrogen β Receptor Activity'
              g.valueField = 'estrogenBeta'
              g.type = 'smoothedLine'
              g.lineThickness = 1
              g.fillAlphas = 1
              g.balloonFunction = (graphDataItem, graph) ->
                day = Math.floor( parseInt(graphDataItem.category) / 24 ) + 1
                hour = Math.floor( ( parseInt(graphDataItem.category) / 24 - day + 1 ) / ( 1 / 24 ) )
                return graphDataItem.values.value + 'x - Day: ' + day + ' Hour: ' + hour

              that.pharmacodynamics.addGraph g

              g = new AmCharts.AmGraph()
              g.lineColor = 'rgba(81, 230, 80, 1)' # green
              g.title = 'Gucocorticoid Receptor Activity'
              g.valueField = 'glucocorticoid'
              g.type = 'smoothedLine'
              g.lineThickness = 1
              g.fillAlphas = 1
              g.balloonFunction = (graphDataItem, graph) ->
                day = Math.floor( parseInt(graphDataItem.category) / 24 ) + 1
                hour = Math.floor( ( parseInt(graphDataItem.category) / 24 - day + 1 ) / ( 1 / 24 ) )
                return graphDataItem.values.value + 'x - Day: ' + day + ' Hour: ' + hour

              that.pharmacodynamics.addGraph g

              that.pharmacodynamics.dataProvider = receptorLevels = []
              for item in levels
                a = {
                  hour : item.hour
                  androgen : 0
                  progesterone : 0
                  estrogenAlpha : 0
                  estrogenBeta : 0
                  glucocorticoid : 0
                }

                for compound, mg of item
                  if compound.startsWith 'C-'
                    c = Compounds(compound)
                    a.androgen += mg * c.androgenReceptor
                    a.progesterone += mg * c.progesteroneReceptor
                    a.estrogenAlpha += mg * c.estrogenAlphaReceptor
                    a.estrogenBeta += mg * c.estrogenBetaReceptor
                    a.glucocorticoid += mg * c.glucocorticoidReceptor

                a.androgen = Math.round a.androgen
                a.progesterone = Math.round a.progesterone
                a.estrogenAlpha = Math.round a.estrogenAlpha
                a.estrogenBeta = Math.round a.estrogenBeta
                a.glucocorticoid = Math.round a.glucocorticoid

                receptorLevels.push a

              that.pharmacodynamics.validateData()

              $timeout -> do that._update if that.pharmacodynamics.chartData.length is 0




      @_update = update = _.debounce update, 250

      #------------------------------------------
      hashkey = null
      Object.defineProperty this, '$$hashkey', {
        enumerable : false
        }

      #------------------------------------------
      owner = ''
      Object.defineProperty this, 'owner', {
        enumerable : true
        get        : -> return owner
        set        : (x) ->
          if owner isnt x
            owner = x
            do save
        }

      #------------------------------------------
      title = ''
      Object.defineProperty this, 'title', {
        enumerable : true
        get        : -> return title
        set        : (x) ->
          if title isnt x
            title = x
            do save
        }

      #------------------------------------------
      description = ''
      Object.defineProperty this, 'description', {
        enumerable : true
        get        : -> return description
        set        : (x) ->
          if description isnt x
            description = x
            do save
        }

      #------------------------------------------
      if Athlete.ffmi <= 20 then experience = 'Beginner'
      if 25 > Athlete.ffmi > 20 then experience = 'Intermediate'
      if Athlete.ffmi > 25 then experience = 'Advanced'
      Object.defineProperty this, 'experience', {
        enumerable : true
        get        : -> return experience
        set        : (x) -> # Beginner, Intermediate, Advanced
          if experience isnt x
            experience = x
            do save
        }

      #------------------------------------------
      goal = 'Hypertrophy'
      Object.defineProperty this, 'goal', {
        enumerable : true
        get        : -> return goal
        set        : (x) -> # Strength, Hypertrophy, Recomposition, Performance
          if goal isnt x
            goal = x
            do save
        }

      #------------------------------------------
      components = []
      Object.defineProperty this, 'components', {
        enumerable : true
        get        : -> return components
        set        : (x) ->
          if components isnt x
            components = x
            do save
        }

      #------------------------------------------
      graph = null
      Object.defineProperty this, 'graph', {
        get        : -> return graph
        set        : (x) ->
          graph = AmCharts.makeChart x[0], {
            'type': 'serial'
            'pathToImages': 'http://cdn.amcharts.com/lib/3/images/'
            'categoryField': 'hour'
            'autoMargins': false
            'marginBottom': 0
            'marginLeft': 0
            'marginRight': 0
            'marginTop': 0
            'borderAlpha': 0
            'chartCursor': {
              'selectWithoutZooming': true
              'zoomable': false
              'zooming': false
            }
            'zoomOutButtonImage': ''
            'zoomOutText': ''
            'graphs': []
            'valueAxes': [
              {
                'id': 'ValueAxis-1'
                'stackType': 'regular'#'100%'
                'title': 'Axis title'
                'axisAlpha': 0,
                'gridAlpha': 0,
              }
            ]
            'categoryAxis': {
              'axisAlpha': 0,
              'gridAlpha': 0,
              'minorGridAlpha': 0
            }
            'dataProvider': []
          }

          do that._update

        }

      #------------------------------------------
      pharmacodynamics = null
      Object.defineProperty this, 'pharmacodynamics', {
        get        : -> return pharmacodynamics
        set        : (x) ->
          pharmacodynamics = AmCharts.makeChart x[0], {
            'type': 'serial'
            'pathToImages': 'http://cdn.amcharts.com/lib/3/images/'
            'categoryField': 'hour'
            'autoMargins': false
            'marginBottom': 0
            'marginLeft': 0
            'marginRight': 0
            'marginTop': 0
            'borderAlpha': 0
            'chartCursor': {
              'selectWithoutZooming': true
              'zoomable': false
              'zooming': false
            }
            'zoomOutButtonImage': ''
            'zoomOutText': ''
            'graphs': []
            'valueAxes': [
              {
                'id': 'ValueAxis-1'
                'title': 'Axis title'
                'axisAlpha': 0,
                'gridAlpha': 0,
              }
            ]
            'categoryAxis': {
              'axisAlpha': 0,
              'gridAlpha': 0,
              'minorGridAlpha': 0
            }
            'dataProvider': []
          }

          do that._update

        }

      #------------------------------------------
      priceUSD = 0
      Object.defineProperty this, 'priceUSD', {
        enumerable : true
        get        : -> return if @components.length is 0 then 0 else priceUSD
        set        : (x) ->
          if priceUSD isnt x
            priceUSD = x
        }

      #------------------------------------------
      Object.defineProperty this, 'priceBTC', {
        get        : -> return ( @priceUSD * BTCrate() )
        set        : ->
        }

      #------------------------------------------
      formulations = []
      Object.defineProperty this, 'formulations', {
        enumerable : true
        get        : ->
          do that._update if @components.length isnt 0 and not formulations
          return formulations
        set        : (x) ->
          if formulations isnt x
            formulations = x
        }

      #------------------------------------------
      schedule = []
      Object.defineProperty this, 'schedule', {
        get        : ->
          do update if @components.length isnt 0 and not schedule
          return schedule
        set        : (x) ->
          if schedule isnt x
            schedule = x
        }

      #------------------------------------------
      Object.defineProperty this, 'length', {
        enumerable : true
        get        : -> schedule.length - 1
        set        : -> do update
        }

      $rootScope.$on 'ProtocolService : Update Protocol', (e, data) ->
        if data._id is that._id then $rootScope.$evalAsync ->
          _.extend that, data
          that.components = []
          _.each data.components, (component) ->
            c = new Regimen component.compound.id, that
            _.extend c, component
            that.components.push c

      $rootScope.$on 'ProtocolService : Set Protocol Complete', (e, data) ->
        that._rev = data.rev if data.id is that._id

    addComponent         : (cid) ->
      @components.unshift new Regimen(cid, this)
      do @_update
      do @_save

    removeComponent      : (r) ->
      @components.splice r, 1
      do @_update
      do @_save


  window.ProtocolService = cache = {}
  newProtocol = null

  $rootScope.$on 'ProtocolService : New Protocol Complete', (e, data) ->
    $rootScope.$evalAsync ->
      newProtocol._id = data._id
      newProtocol.owner = Athlete._id
      cache[data._id] = newProtocol

  $rootScope.$on 'ProtocolService : Search Results', (e, data) ->

  return (id, destroy = false) ->
      return cache[id] if id? and cache[id]? and not destroy
      if id?
        if not destroy
          cache[id] = new Protocol
          cache[id]._id = id
          PubNub 'ProtocolService : Get Protocol', cache[id]
          return cache[id]
        if destroy
          PubNub 'ProtocolService : Delete Protocol', cache[id]
          delete cache[id]
      else
        newProtocol = new Protocol
        PubNub 'ProtocolService : New Protocol', newProtocol
        return newProtocol

]
