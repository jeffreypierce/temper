class Collection
  constructor: (val, temp, collection) ->
    @tonic = temp.tonic
    @notes = []
    @name = 'unknown'
   
    if window?
      @_play = temp.play
      @_pluck = temp.pluck
      
    _collectionFromName = (val) =>
      if collection[val]
        @name = val
        for interval in collection[val]
          @notes.push new Interval(interval, temp)
      else
        throw new TypeError("Name #{val} is not a valid argument")

    _collectionFromArray = (val) =>
      

      positions = []
      for note, i in val
        if note.indexOf(',') > -1
          complexInterval = note.split(',')
          note = complexInterval[0].trim()
          direction = complexInterval[1].trim()
          octave = complexInterval[2].trim()
          interval = new Interval(note, temp, direction, octave)
        else
          interval = new Interval(note, temp)

        positions.push interval.intervalName
        @notes.push interval

      for key, value of collection
        if JSON.stringify(value) is JSON.stringify(positions)
          @name = key
          break

    _collectionFromName(val) if utils.type(val) is 'string'
    _collectionFromArray(val) if utils.type(val) is 'array'

    @frequencies = [@tonic.frequency]
    @names = [@tonic.name]
    @midiNotes = [@tonic.midiNote]
    for note in @notes
      @frequencies.push(note.frequency)
      @names.push(note.name)
      @midiNotes.push(note.midiNote)