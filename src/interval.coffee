intervals = ['U','m2','M2','m3','M3','P4','d5','P5','m6','M6','m7','M7','O']

intervals_full = [
  'unison'
  'minor second'
  'major second'
  'minor third'
  'major third'
  'perfect fourth'
  'diminished fifth'
  'perfect fifth'
  'minor sixth'
  'major sixth'
  'minor seventh'
  'major seventh'
  'octave'
]

class Interval extends Note
  constructor: (val, temp, @direction="up", @octave='') ->
    @tonic = temp.tonic

    _noteFromInterval = (val) =>
      @intervalName = val
      position = intervals.indexOf val

      noteArray = @tonic.getNoteArray()
      intervalOctave = @tonic.octave

      if @direction is 'up'
        intervalNumber = noteArray.indexOf(@tonic.letter) + position
        intervalOctave += 1 if intervalNumber >= 12
      else if @direction is 'down'
        intervalNumber = noteArray.indexOf(@tonic.letter) - position

        if intervalNumber < 0
          intervalOctave -= 1
          intervalNumber += 12
      intervalNote = noteArray[intervalNumber % 12] + intervalOctave.toString()

    _intervalNamefromNoteName = =>
      # TODO: this is pretty precarious -- refactor
      rootNoteArray = @getNoteArray.call @tonic
      noteArray = @getNoteArray()
      rootPosition = rootNoteArray.indexOf @tonic.letter
      offsetPosition = noteArray.indexOf @letter
      @direction = 'down'
      position = (12 - offsetPosition + rootPosition) % 12

      if @tonic.octave < @octave or (@tonic.octave is @octave and offsetPosition > rootPosition)
        offsetPosition +=12 if offsetPosition < rootPosition
        position = offsetPosition - rootPosition
        @direction = 'up'

      intervals[position]

    if intervals.indexOf(val) > -1
      val = _noteFromInterval(val)

    super(val, temp)

    @intervalName = _intervalNamefromNoteName() if !utils.type(@intervalName)
    if @tonic.name is @name
      @direction = '-'

    @frequencies = [@tonic.frequency, @frequency]
    @names = [@tonic.name, @name]
    @midiNotes = [@tonic.midiNote, @midiNote]

if window?
  Interval::play = (length) ->
    @_play.call(this, length, 2)
    @_play.call(@tonic, length, 2)

  Interval::pluck=  (length) ->
    @_pluck.call(this, length, 2)
    @_pluck.call(@tonic, length, 2)