chords =
  'maj': [M3, P5]
  'maj6': [M3, P5, M6]
  'maj7': [M3, P5, M7]
  'majb6': [M3, P5, m6]
  'majb7': [M3, P5, m7]
  'min6': [m3, P5, m6]
  'min7': [m3, P5, m7]
  'minM7': [m3, P5, M7]
  'min': [m3, P5]
  'aug': [M3, m6]
  'aug7': [M3, m6, M7]
  'dim': [m3, d5]
  'dim7': [m3, d5, M6]
  'sus4': [P4, P5]
  'sus2': [M2, P5]
  'dream': [P4,d5,P5]

class Chord extends Collection
  constructor: (chord, temp) ->
    super(chord, temp, chords)
      
if window?
  Chord::play = (length) ->
    @_play.call(@tonic, length, @notes.length + 1)
    for note in @notes then do (note) =>
      @_play.call(note, length, @notes.length + 1)

    this

  Chord::pluck =  (length) ->
    @_pluck.call(@tonic, length, @notes.length + 1)
    for note in @notes then do (note) =>
      @_pluck.call(note, length, @notes.length + 1)

    this