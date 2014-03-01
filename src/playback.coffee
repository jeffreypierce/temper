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
      samples = new Float32Array(context.sampleRate)

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
