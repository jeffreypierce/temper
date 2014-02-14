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
  'Prometheus':['M2','M3','d5','M6','m7','O']

class Scale extends Collection
  constructor: (scale, temp) ->
    super(scale, temp, scales)

if window?
  Scale::play = (length = 1) ->
    @_play.call(@tonic, length, 3)
    for note, i in @notes then do (note) =>
      setTimeout ( =>
        @_play.call(note, length, 3)
      ), length * 1000 / 2 * (i + 1)

  Scale::pluck =  (length = 1) ->
    @_pluck.call(@tonic, length, 3)
    for note, i in @notes then do (note) =>
      setTimeout ( =>
        @_pluck.call(note, length, 3)
      ), length * 1000  / 2 * (i + 1)