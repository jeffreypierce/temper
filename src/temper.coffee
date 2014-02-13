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
        @note(@tonic.name)

        if(@_interval)
          @interval(@_interval.name)

      this
    else
      @_temperament

  interval: (interval, direction, octave) ->
    if interval?
      @_interval = new Interval(interval, this, direction, octave)
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

# node or browser
root = this

temper = (val, tuningFrequency, temperament) ->
  new Temper(val, tuningFrequency, temperament)

temper.note = (val) ->
  new Temper(val)

temper.chords = (val) ->
  utils.list.call(chords, val)
  
temper.intervals = (val) ->
  utils.list.call(intervals, val, true)

temper.temperaments = (val) ->
  utils.list.call(temperaments, val)

temper.centOffset = utils.centOffset

if typeof exports isnt "undefined"
  module.exports = temper
else
  root["temper"] = temper