class Collection
  constructor: (item, temp, collection) ->
    @tonic = temp.tonic
    @notes = []
    @name = 'unknown'
   
    if window?
      @_play = temp.play
      @_pluck = temp.pluck
      
    _collectionFromName = (item) =>
      if collection[item]
        @name = item
        for interval in collection[item]
          @notes.push new Interval(interval, temp)
      else
        throw new TypeError('Name "' + item + '" is not a valid argument')

    _collectionFromArray = (item) =>
      positions = []
      for note, i in item
        interval = new Interval(note, temp)
        positions.push interval.intervalName
        @notes.push interval

      for key, value of collection
        if JSON.stringify(value) is JSON.stringify(positions)
          @name = key
          break

    _collectionFromName(item) if utils.type(item) is 'string'
    _collectionFromArray(item) if utils.type(item) is 'array'

    @frequencies = [@tonic.frequency]
    @names = [@tonic.name]
    @midiNotes = [@tonic.midiNote]
    for note in @notes
      @frequencies.push(note.frequency)
      @names.push(note.name)
      @midiNotes.push(note.midiNote)