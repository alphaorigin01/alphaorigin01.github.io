ordersByAthlete = (doc) ->
  if doc._id.indexOf('order_athlete_') is 0
    emit(doc.athlete, null)

ordersOfProtocol = (doc) ->
  if doc._id.indexOf('order_athlete_') is 0
    emit(id, protocol.qty) for id, protocol of doc.cart

totalPublicProtocols = (doc) ->
  if doc._id.indexOf('protocol_') is 0 and doc.title isnt '' and doc.description isnt ''
    emit('all', null)

searchIndexes = (doc) ->
  if doc._id.indexOf('protocol_') is 0 and doc.owner isnt 'deleted'
    index 'public', if doc.title isnt '' and doc.description isnt '' then true else false
    index 'owner', doc.owner
    index 'length', doc.length
    index 'goal', doc.goal
    index 'experience', doc.experience
    for c in doc.components
      index 'compound', c.compound.id
