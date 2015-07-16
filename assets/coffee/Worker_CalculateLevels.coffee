'use strict'

# halflife
# bioavailability
# activeTarget
# duration
# interval

@onmessage = (e) ->
  data = e.data
  decayConstant      =  Math.log(2) / data.halfLife
  doseActivity       =  (dose, day) -> dose * data.bioavailability * Math.pow( Math.E, -( day * decayConstant )) # Active amount on day where day is relative to initial dose.
  rateOfRelease      =  (dose, day) -> decayConstant * doseActivity(dose, day) # The rate of compound release at a given day

  levels = []

  # Find the dose
  min = 0
  max = 0

  for infusion in [ 0..( data.duration - data.interval ) ] by data.interval
    max += rateOfRelease( 100, infusion )
    min += rateOfRelease( 100, infusion ) if infusion > 0

  avg = ( min + max ) * 0.5
  dose = ( data.activeTarget / avg ) * 100

  # Find the loading dose
  min = 0
  max = 0

  for infusion in [ 0..( data.duration - data.interval ) ] by data.interval
    max += rateOfRelease( dose, infusion )
    min += rateOfRelease( dose, infusion ) if infusion > 0

  load = ( max / rateOfRelease(dose, 0) ) * dose
  maxLoad = data.density * 3
  load = maxLoad if load > maxLoad

  # Calculate levels
  for infusion in [ 0..( data.duration - data.interval ) ] by data.interval
    start = ( infusion * 24 )
    rate = 1
    hour = start
    while rate >= 1
      rate = if infusion is 0 then rateOfRelease( load, ( ( hour - start ) / 24 ) ) else rateOfRelease( dose, ( ( hour - start ) / 24 ) )
      levels[ hour ] = if levels[ hour ]? then levels[ hour ] + rate else rate
      hour += 1

  max = levels[ ( data.duration - data.interval ) * 24 ]
  min = levels[ data.duration * 24 ]

  postMessage {
    levels      :  levels
    min         :  min
    max         :  max
    avg         :  ( min + max ) * 0.5
    dose        :  dose
    loadingDose :  load
  }

  do close
