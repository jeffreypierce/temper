describe "Note Tests", ->

  it "has correct note name", ->
    noteA4 = temper.note(440)
    expect(noteA4.note().name).toBe("A4")
    expect(noteA4.note().octave).toBe(4)
    expect(noteA4.note().letter).toBe("A")
    expect(noteA4.note().accidental).toBe("")

  it "has correct frequency", ->
    note440 = temper.note("A4")
    expect(note440.note().frequency).toBe(440)
    expect(note440.note().octave).toBe(4)
    expect(note440.note().letter).toBe("A")
    expect(note440.note().accidental).toBe("")

  it "has correct accidental", ->
    noteFSharp = temper.note("F#5")
    expect(noteFSharp.note().accidental).toBe("#")
    expect(noteFSharp.note().name).toBe("F#5")
    expect(noteFSharp.note().octave).toBe(5)
    expect(noteFSharp.note().letter).toBe("F#")

  it "secondary syntax", ->
    noteBb = temper("Bb1")
    expect(noteBb.note().name).toBe("Bb1")
    expect(noteBb.note().octave).toBe(1)
    expect(noteBb.note().letter).toBe("Bb")
    expect(noteBb.note().accidental).toBe("b")

describe "Interval Tests", ->
  it "create interval from frequency / interval", ->
    m3 = temper(220).interval('m3')
    expect(m3.name).toBe("C4")
    expect(m3.frequency).toBe(261.626)

  it "create interval from frequency / interval, down", ->
    m3 = temper(220).interval('m3', "down")
    expect(m3.name).toBe("F#3")
    expect(m3.frequency).toBe(184.997)

  it "create interval from note / interval", ->
    P5 = temper("G6").interval('P5')
    expect(P5.name).toBe("D7")
    expect(P5.frequency).toBe(2349.318)

  it "create interval from note / interval, down", ->
    P5 = temper("G6").interval('P5', "down")
    expect(P5.name).toBe("C6")
    expect(P5.frequency).toBe(temper("C6").note().frequency)

  it "create interval from frequency / frequency", ->
    f880 = temper(440).interval(880)
    expect(f880.intervalName).toBe("U")
    expect(f880.name).toBe("A5")

  it "create interval from frequency / frequency, down", ->
    f880 = temper(440).interval(880, "down") # frequency wins out over direction
    expect(f880.direction).toBe("up")
    expect(f880.name).toBe("A5")

  it "create interval from note / note", ->
    ASharp = temper("A2").interval("A#3")
    expect(ASharp.intervalName).toBe("m2")
    expect(ASharp.frequency).toBe(233.082)

  it "create interval from note / note, down", ->
    ASharp = temper("A5").interval("A#4", "down")
    expect(ASharp.intervalName).toBe("M7")
    expect(ASharp.frequency).toBe(temper("A#4").note().frequency)
