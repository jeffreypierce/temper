chords =
  'maj': ['M3', 'P5']
  'maj6': ['M3', 'P5', 'M6']
  'maj7': ['M3', 'P5', 'M7']
  'majb6': ['M3', 'P5', 'm6']
  'majb7': ['M3', 'P5', 'm7']
  'min6': ['m3', 'P5', 'm6']
  'min7': ['m3', 'P5', 'm7']
  'minM7': ['m3', 'P5', 'M7']
  'min': ['m3', 'P5']
  'aug': ['M3', 'm6']
  'aug7': ['M3', 'm6', 'M7']
  'dim': ['m3', 'd5']
  'dim7': ['m3', 'd5', 'M6']
  'sus4': ['P4', 'P5']
  'sus2': ['M2', 'P5']
  'dream': ['P4','d5','P5']

class Chord
  constructor: (chord, temp) ->

    @notes = []
    @name = 'unknown'
    @tonic = temp.tonic

    if window?
      @_play = temp.play
      @_pluck = temp.pluck
      
    _chordFromName = (chord) =>
      if chords[chord]
        @name = chord
        for interval in chords[chord]
          @notes.push new Interval(interval, temp)
      else
        throw new TypeError('Chord name "' + chord + '" is not a valid argument')

    _chordFromArray = (chord) =>
      chordPositions = []
      for note, i in chord
        interval = new Interval(note, temp)
        chordPositions.push interval.intervalName
        @notes.push interval

      for key, value of chords
        if JSON.stringify(value) is JSON.stringify(chordPositions)
          @name = key
          break

    _chordFromName(chord) if utils.type(chord) is 'string'
    _chordFromArray(chord) if utils.type(chord) is 'array'

    @frequencies = [@tonic.frequency]
    @names = [@tonic.name]
    @midiNotes = [@tonic.midiNote]
    for note in @notes
      @frequencies.push(note.frequency)
      @names.push(note.name)
      @midiNotes.push(note.midiNote)
      

if window?
  Chord::play = (length) ->
    @_play.call(@tonic, length, @notes.length + 1)
    for note in @notes then do (note) =>
      @_play.call(note, length, @notes.length + 1)

  Chord::pluck =  (length) ->
    @_pluck.call(@tonic, length, @notes.length + 1)
    for note in @notes then do (note) =>
      @_pluck.call(note, length, @notes.length + 1)