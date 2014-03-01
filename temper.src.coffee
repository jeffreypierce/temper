utils =
  type: (obj) ->
    if obj == undefined or obj == null
      return false
    classType = {
      '[object Number]': 'number'
      '[object String]': 'string'
      '[object Array]': 'array',
      '[object Object]': 'object'
    }
    classType[toString.call(obj)]

  normalize: (num, precision = 3) ->
    multiplier = Math.pow(10, precision)
    Math.round(num * multiplier) / multiplier

  list: (val, arr)->
    if val and this[val]
      this[val]
    else
      if arr
        for name in this
          name
      else
        for key of this
          key

  centOffset: (freq1, freq2) ->
    Math.round(1200 * Math.log(freq1 / freq2) / Math.log 2)

  ratioFromCents: (cents) ->
    Math.pow(2, (cents / 100 / 12))

  stepRatio: Math.log Math.pow(2, 1 / 12)




notesFlat = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']
notesSharp = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B']
flatKeys = ['C','F','Bb','Eb','Ab','Db','Gb', 'Cb']

# note_names_enharmonic =
#   'C': 'B#'
#   'E': 'E#'
#   'F': 'E3'
#   'B': 'Cb'

class Note
  constructor: (val, temp) ->
    if window?
      @_play = temp.play
      @_pluck = temp.pluck
    console.log 'note'
    @rootFrequency = temp.rootFrequency()
    @temperament = temp._temperament

    referenceFrequency = =>
      @rootFrequency * Math.pow(2, @octave)

    noteFromName = (noteName) =>
      getFrequencyFromNoteLetter = =>
        noteArray = @getNoteArray(@letter)
        position = noteArray.indexOf @letter
        ratio = utils.ratioFromCents(temperaments[@temperament][position])

        utils.normalize ratio * referenceFrequency()

      parsed = /// ([A-Ga-g]) # match letter
                   ([b#]?) # match accidental
                   (\d+) # match octave
                ///.exec noteName
      if(parsed?)
        @octave = parseInt(parsed[3], 10)
        @accidental = parsed[2]
        @letter = parsed[1].toUpperCase()
        @letter += @accidental if @accidental?
        @frequency = utils.normalize getFrequencyFromNoteLetter()
        @name = val

      else
        throw new TypeError("Note name #{noteName} is not a valid argument")

    noteFromFreq = (freq) =>
      getNoteLetterFromFrequency = =>
        baseFreq = Math.log @frequency / referenceFrequency()
        noteNumber = Math.round baseFreq / utils.stepRatio
        @octave += 1 if noteNumber is 12
        noteArray = @getNoteArray()

        noteArray[noteNumber % 12]

      if 30000 > freq > 0
        @octave = Math.floor(Math.log(freq / @rootFrequency) / Math.log 2)
        @frequency = utils.normalize freq
        @letter = getNoteLetterFromFrequency()
        @name = @letter + @octave.toString()
        accidental = @name.match(/[b#]/)
        @accidental = if accidental? then accidental else ""

      else
        throw new RangeError("Frequency #{freq} is not valid")

    noteFromName(val) if utils.type(val) is "string"
    noteFromFreq(val) if utils.type(val) is "number"

    @midiNote = Math.round(12 * Math.log(@frequency/440) / Math.log(2) + 69)

  getNoteArray: (letter) ->
    if flatKeys.indexOf(letter) > -1 then notesFlat else notesSharp

if window?
  Note::play = (length) ->
    @_play.call(this, length)

  Note::pluck=  (length) ->
    @_pluck.call(this, length)

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

# intervals_full = [
#   'unison'
#   'minor second'
#   'major second'
#   'minor third'
#   'major third'
#   'perfect fourth'
#   'diminished fifth'
#   'perfect fifth'
#   'minor sixth'
#   'major sixth'
#   'minor seventh'
#   'major seventh'
#   'octave'
# ]

class Interval extends Note
  constructor: (val, temp, @direction="up", octaveOffset="0") ->
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

      if @tonic.octave < @octave or (@tonic.octave is @octave and offsetPosition > rootPosition)
        offsetPosition +=12 if offsetPosition < rootPosition
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
class Collection
  constructor: (val, temp, collection) ->
    @tonic = temp.tonic
    @notes = []
    @name = 'unknown'
   
    if window?
      @_play = temp.play
      @_pluck = temp.pluck
      
    collectionFromName = (val) =>
      if collection[val]
        @name = val
        for interval in collection[val]
          @notes.push new Interval(interval, temp)
      else
        throw new TypeError("Name #{val} is not a valid argument")

    collectionFromArray = (val) =>
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

    collectionFromName(val) if utils.type(val) is 'string'
    collectionFromArray(val) if utils.type(val) is 'array'

    @frequencies = [@tonic.frequency]
    @names = [@tonic.name]
    @midiNotes = [@tonic.midiNote]
    for note in @notes
      @frequencies.push(note.frequency)
      @names.push(note.name)
      @midiNotes.push(note.midiNote)

    this
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
temperaments =
  'Equal': [0,100,200,300,400,500,600,700,800,900,1000,1100,1200]
  'Pythagorean': [0,113.69,203.91,294.13,407.82,498.04,611.73,701.95,815.64,905.87,996.09,1109.78,120]
  'Natural': [0,111.74,203.91,315.64,386.31,498.05,603,702,813.69,884.36,1017.6,1088.27,1200]
  '1/3 comma Meantone': [0,63.50,189.57,315.64,379.14,505.21,568.72,694.79,758.29,884.36,1010.43,1073.93,1200]
  '2/7 comma Meantone': [0,70.67,191.62,312.57,383.24,504.19,574.86,695.81,766.48,887.43,1008.38,1079.05,1200]
  '1/4 comma Meantone': [0,76.05,193.16,310.26,386.31,503.42,579.47,696.58,772.63,889.74,1006.84,1082.89,1200]
  '1/5 comma Meantone': [0,83.58,195.31,307.04,390.61,502.35,585.92,697.65,781.23,892.96,1004.69,1088.27,1200]
  '1/6 comma Meantone': [0,88.59,196.74,304.89,393.48,501.63,590.22,698.37,786.96,895.11,1003.26,1091.85,1200]
  '1/8 comma Meantone': [0,94.87,198.53,302.20,397.07,500.73,595.60,699.27,794.13,897.80,1001.47,1096.33,1200]
  'Ordinaire': [0,86.81,193.16,296.09,386.31,503.42,584.85,696.58,788.76,889.74,1005.22,1082.89,1200]
  'Werckmeister III':[0,90.22,192.18,294.14,390.23,498.05,588.27,696.09,792.18,888.27,996.09,1092.18,1200]
  'Kirnberger': [0,91,192,296,387,498,591,696,792,890,996,1092,1200]
  'Kirnberger III': [0,90.18,193.16,294.13,386.31,498.04,590.22,696.58,792.18,889.74,996.09,1088.27,1200]
  'Young': [0,93.69,195.91,298.13,391.82,502.04,591.73,697.96,796.18,893.87,1000.09,1089.78,1200]

temperaments['1/11 comma Meantone'] = temperaments['Equal']
temperaments['Salinas'] = temperaments['1/3 comma Meantone']
temperaments['Aaron'] = temperaments['1/4 comma Meantone']
temperaments['Silbermann'] = temperaments['1/5 comma Meantone']

class Temper
  constructor: (val, @tuningFrequency = 440, @_temperament = 'Equal') ->
    if val?
      @tonic = new Note(val, this)

    this

  rootFrequency: ->
    ratio = utils.ratioFromCents temperaments[@_temperament][9]
    @tuningFrequency / Math.pow(2, 4) / ratio

  note: (noteName) ->
    if noteName?
      @tonic = new Note(noteName, this)
    else
      @tonic

  temperament: (temperament) ->
    if temperament?

      if temperaments[temperament]
        @_temperament = temperament

        @tonic = @note(@tonic.name)

        if(@_interval?)
          @interval(@_interval.name)

        if(@_scale?)
          @scale(@_scale.names)

        if(@_chord?)
          @chord(@_chord.name)

      this
    else
      @_temperament

  interval: (interval, direction, octaveOffset) ->
    if interval?
      @_interval = new Interval(interval, this, direction, octaveOffset)
    else
      @_interval

  scale: (scale) ->
    if scale?
      @_scale = new Scale(scale, this)
    else
      @_scale

  chord: (chord) ->
    if chord?
      @_chord = new Chord(chord, this)
    else
      @_chord

temper = (val, tuningFrequency, temperament) ->
  new Temper(val, tuningFrequency, temperament)

temper.note = (val) ->
  new Temper(val)

temper.tonic = (val) ->
  new Temper(val)

temper.chords = (val) ->
  utils.list.call(chords, val)
  
temper.intervals = (val) ->
  utils.list.call(intervals, val, true)

temper.temperaments = (val) ->
  utils.list.call(temperaments, val)

temper.centOffset = utils.centOffset

# node or browser
root = this

if typeof exports isnt "undefined"
  module.exports = temper
else
  root["temper"] = temper
if window?
  window.AudioContext = window.AudioContext || window.webkitAudioContext
  context = new AudioContext()
  
  Temper::play = (length = 2, numOfNotes = 1) ->
    volume = 0.9 / numOfNotes
    begin = context.currentTime
    end = begin + length

    osc = context.createOscillator()
    osc.type = 'sine'
    osc.frequency.value = if @frequency then @frequency else @tonic.frequency

    vol = context.createGain()
    vol.gain.setValueAtTime(0, begin)
    vol.gain.linearRampToValueAtTime(volume, end - (length * 0.5))
    vol.gain.linearRampToValueAtTime(0, end)

    osc.connect vol
    vol.connect context.destination

    osc.start begin
    osc.stop end

  Temper::pluck = (length = 2, numOfNotes = 1) ->
    volume = 0.9 / numOfNotes
    begin = context.currentTime
    end = begin + length

    _karplusStrong = (freq) ->
      noise = []
      samples = new Float32Array context.sampleRate
      
      # generate noise
      period = Math.floor(context.sampleRate / freq)
      i = 0
      while i < period
        noise[i] = 2 * Math.random() - 1
        i++

      prevIndex = 0
      _generateSample = ->
        index = noise.shift()
        sample = (index + prevIndex) / 2
        prevIndex = sample
        noise.push sample
        sample

      # generate decay
      amp = (Math.random() * 0.5) + 0.4
      j = 0
      while j < context.sampleRate
        samples[j] = _generateSample()
        decay = amp - (j / context.sampleRate) * amp
        samples[j] = samples[j] * decay
        j++

      samples

    vol = context.createGain()
    pluck = context.createBufferSource()

    frequency = if @frequency then @frequency else @tonic.frequency
    samples = _karplusStrong frequency
    audioBuffer = context.createBuffer(1, samples.length, context.sampleRate)

    audioBuffer.getChannelData(0).set samples
    pluck.buffer = audioBuffer

    pluck.connect vol
    vol.connect context.destination
    vol.gain.value = volume
    pluck.start begin
    pluck.stop end
