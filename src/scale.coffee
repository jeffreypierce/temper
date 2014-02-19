scales =
  'Major': [M2, M3, P4, P5, M6, M7, O]
  'Melodic Minor': [M2, m3, P4, P5, m6, m7, O]
  'Harmonic Minor': [M2, m3, P4, P5, m6, M7, O]
  'Chromatic': [m2, M2, m3, M3, P4, d5, P5, m6, M6, m7, M7, O]
  'Ionian': [M2, M3, P4, P5, M6, M7, O]
  'Dorian': [M2, m3, P4, P5, M6, m7, O]
  'Phrygian': [m2, m3, P4, P5, m6, m7, O]
  'Lydian': [M2, M3, A4, P5, M6, M7, O]
  'Mixolydian': [M2, M3, P4, P5, M6, m7, O]
  'Aeolian': [M2, m3, P4, P5, m6, m7, O]
  'Locrian': [m2, m3, P4, d5, m6, m7, O]
  'Whole Tone': [M2, M3, d5, m6, m7, O]
  'Acoustic': [M2, M3, d5, P5, M6, m7, O]
  'Enigmatic': [m2, M3, d5, m6, m7, M7, O]
  'Enigmatic Minor': [m2, m3, d5, P5, m7, M7, O]
  'Neapolitan': [m2, m3, P4, P4, P5, m6, M7, O]
  'Prometheus':[M2, M3, d5, M6, m7, O]
  'In Sen': [m2, P4, P5, m7, O]
  'In': [m2, P4, P5, m6, O]
  'Hirajoshi': [m2, P4, P5, m6, O]
  'Yo': [M2, P4, P5, M6, O]
  'Iwato': [m2, P4, d5, m7, O]
  'Pentatonic': [M2, M3, P5, M6, O]
  'Octatonic I': [M2, m3, P4, d5, m6, M6, M7, O]
  'Octatonic II': [m2, m3, M3, d5, P5, M6, m7, O]
  'Tritone': [m2, M3, d5, P5, m7, O]
  'Hungarian': [M2, m3, d5, P5, m6, M7, O]


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

    this

  Scale::pluck =  (length = 1) ->
    @_pluck.call(@tonic, length, 3)
    for note, i in @notes then do (note) =>
      setTimeout ( =>
        @_pluck.call(note, length, 3)
      ), length * 1000  / 2 * (i + 1)

      this