scales =
  'Major': ['M2','M3','P4','P5', 'M6', 'M7', 'O']
  'Minor': ['M2','m3','P4','P5', 'm6', 'm7', 'O']
  'Chromatic': ['m2','M2','m3','M3','P4','d5','P5','m6','M6','m7','M7','O']
  'Ionian': ['M2','M3','P4','P5', 'M6', 'M7', 'O']
  'Dorian': ['M2','m3','P4','P5','M6','m7','O']
  'Phrygian': ['m2','m3','P4','P5','m6','m7','O']
  'Lydian': ['M2','M3','A4','P5','M6','M7','O']
  'Mixolydian': ['M2','M3','P4','P5','M6','m7','O']
  'Aeolian': ['M2','m3','P4','P5','m6','m7','O']
  'Locrian': ['m2','m3','P4','d5','m6','m7','O']

class Scale
  constructor: (scale, temp) ->
    @tonic = temp.tonic
    @notes = []
    @name = 'unknown'

    if window?
      @_play = temp.play
      @_pluck = temp.pluck

    _scaleFromName = (scale) =>
      if scales[scale]
        @name = scale
        for interval in scales[scale]
          @notes.push new Interval(interval, temp)
      else
        throw new TypeError('Scale name "' + scale + '" is not a valid argument')

    _scaleFromArray = (scale) =>
      scalePositions = []
      for note, i in scale
        interval = new Interval(note, temp)
        scalePositions.push interval.intervalName
        @notes.push interval

      for key, value of scales
        if JSON.stringify(value) is JSON.stringify(scalePositions)
          @name = key
          break

    _scaleFromName(scale) if utils.type(scale) is 'string'
    _scaleFromArray(scale) if utils.type(scale) is 'array'

    @frequencies = [@tonic.frequency]
    @names = [@tonic.name]
    @midiNotes = [@tonic.midiNote]
    for note in @notes
      @frequencies.push(note.frequency)
      @names.push(note.name)
      @midiNotes.push(note.midiNote)

if window?
  Scale::play = (length = 2) ->
    @_play.call(@tonic, length, 2)
    for note, i in @notes then do (note) =>
      setTimeout ( =>
        @_play.call(note, length, 2)
      ), length * 1000 / 2 * (i + 1)

  Scale::pluck =  (length = 2) ->
    @_pluck.call(@tonic, length, 2)
    for note, i in @notes then do (note) =>
      setTimeout ( =>
        @_pluck.call(note, length, 2)
      ), length * 1000  / 2 * (i + 1)