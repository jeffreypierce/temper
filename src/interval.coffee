U = 'U'
m2 = 'm2'
M2 = 'M2'
m3 = 'm3'
M3 = 'M3'
P4 = 'P4'
d5 = 'd5'
P5 = 'P5'
m6 = 'm6'
M6 = 'M6'
m7 = 'm7'
M7 = 'M7'
O = 'O'
A4 = 'd5'

intervals = [U, m2, M2, m3, M3, P4, d5, P5, m6, M6, m7, M7, O ]

class Interval extends Note
  constructor: (val, temp, @direction = "up", octaveOffset = "0") ->
    @tonic = temp.tonic

    noteFromInterval = (val, octaveOffset) =>
      @intervalName = val
      position = intervals.indexOf val
      noteArray = @tonic.getNoteArray()
      intervalOctave = @tonic.octave

      if @direction is 'up'
        intervalOctave += parseInt(octaveOffset, 10)
        intervalNumber = noteArray.indexOf(@tonic.letter) + position
        intervalOctave += 1 if intervalNumber >= 12

      else if @direction is 'down'
        intervalOctave -= parseInt(octaveOffset, 10)
        intervalNumber = noteArray.indexOf(@tonic.letter) - position
        if intervalNumber < 0
          intervalNumber += 12
          intervalOctave -= 1

      intervalNote = noteArray[intervalNumber % 12] + intervalOctave.toString()

    intervalNamefromNoteName = =>
      tonicNoteArray = @getNoteArray.call @tonic
      noteArray = @getNoteArray()
      rootPosition = tonicNoteArray.indexOf @tonic.letter
      offsetPosition = noteArray.indexOf @letter

      @direction = 'down'
      position = (12 - offsetPosition + rootPosition) % 12

      if @tonic.octave < @octave or
      (@tonic.octave is @octave and offsetPosition > rootPosition)
        offsetPosition += 12 if offsetPosition < rootPosition
        position = offsetPosition - rootPosition
        @direction = 'up'

      intervals[position]

    if intervals.indexOf(val) > -1
      val = noteFromInterval(val, octaveOffset)

    super(val, temp)

    @intervalName = intervalNamefromNoteName() if !utils.type(@intervalName)

    if @tonic.name is @name
      @direction = '-'

    @frequencies = [@tonic.frequency, @frequency]
    @names = [@tonic.name, @name]
    @midiNotes = [@tonic.midiNote, @midiNote]

if window?
  Interval::play = (length) ->
    @play.call(this, length, 2)
    @play.call(@tonic, length, 2)

  Interval::pluck=  (length) ->
    @pluck.call(this, length, 2)
    @pluck.call(@tonic, length, 2)
