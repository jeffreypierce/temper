notesFlat = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B']
notesSharp = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B']
flatKeys = ['C','F','Bb','Eb','Ab','Db','Gb', 'Cb']

class Note
  constructor: (val, temp) ->
    if window?
      @_play = temp.play
      @_pluck = temp.pluck

    @rootFrequency = temp.rootFrequency()
    @temperament = temp._temperament

    referenceFrequency = =>
      @rootFrequency * Math.pow 2, @octave

    noteFromName = (noteName) =>
      getFrequencyFromNoteLetter = =>
        noteArray = @getNoteArray @letter
        position = noteArray.indexOf @letter
        ratio = utils.ratioFromCents temperaments[@temperament][position]

        utils.normalize ratio * referenceFrequency()

      parsed = /// ([A-Ga-g]) # match letter
                   ([b#]?) # match accidental
                   (\d+) # match octave
                ///.exec noteName
      if parsed?
        @octave = parseInt parsed[3], 10
        @accidental = parsed[2]
        @letter = parsed[1].toUpperCase()
        @letter += @accidental if @accidental?
        @frequency = utils.normalize getFrequencyFromNoteLetter()
        @name = val
        @centOffset = 0

      else
        throw new TypeError "Note name #{noteName} is not a valid argument"

    noteFromFreq = (freq) =>
      getNoteLetterFromFrequency = =>
        baseFreq = Math.log @frequency / referenceFrequency()

        # equal temperament naming
        noteNumber = Math.round baseFreq / Math.log Math.pow(2, 1 / 12)

        @octave += 1 if noteNumber is 12
        noteArray = @getNoteArray()

        noteArray[noteNumber % 12]

      if 20000 > freq > 0
        @octave = Math.floor Math.log(freq / @rootFrequency) / Math.log 2
        @frequency = utils.normalize freq
        @letter = getNoteLetterFromFrequency()
        @name = @letter + @octave.toString()
        accidental = @name.match /[b#]/
        @accidental = if accidental? then accidental else ""
        trueFreq = temper @name
        @centOffset = utils.centOffset @frequency, trueFreq.tonic.frequency,

      else
        throw new RangeError "Frequency #{freq} is not valid"

    noteFromName val if utils.type(val) is "string"
    noteFromFreq val if utils.type(val) is "number"

    @midiNote = Math.round 12 * Math.log(@frequency / 440) / Math.log(2) + 69

  getNoteArray: (letter) ->
    if flatKeys.indexOf(letter) > -1 then notesFlat else notesSharp

if window?
  Note::play = (length) ->
    @_play.call this, length

  Note::pluck=  (length) ->
    @_pluck.call this, length
