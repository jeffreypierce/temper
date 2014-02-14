(function() {
  var Chord, Collection, Interval, Note, Scale, Temper, chords, context, flatKeys, intervals, intervals_full, note_names_enharmonic, notesFlat, notesSharp, root, scales, temper, temperaments, utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  utils = {
    type: function(obj) {
      var classType;
      if (obj === void 0 || obj === null) {
        return false;
      }
      classType = {
        '[object Number]': 'number',
        '[object String]': 'string',
        '[object Array]': 'array',
        '[object Object]': 'object'
      };
      return classType[toString.call(obj)];
    },
    normalize: function(num, precision) {
      var multiplier;
      if (precision == null) {
        precision = 3;
      }
      multiplier = Math.pow(10, precision);
      return Math.round(num * multiplier) / multiplier;
    },
    list: function(val, arr) {
      var key, name, _i, _len, _results, _results1;
      if (val && this[val]) {
        return this[val];
      } else {
        if (arr) {
          _results = [];
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            name = this[_i];
            _results.push(name);
          }
          return _results;
        } else {
          _results1 = [];
          for (key in this) {
            _results1.push(key);
          }
          return _results1;
        }
      }
    },
    centOffset: function(freq1, freq2) {
      return Math.round(1200 * Math.log(freq1 / freq2) / Math.log(2));
    },
    ratioFromCents: function(cents) {
      return Math.pow(2, cents / 100 / 12);
    },
    stepRatio: Math.log(Math.pow(2, 1 / 12))
  };

  notesFlat = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

  notesSharp = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  flatKeys = ['C', 'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb'];

  note_names_enharmonic = {
    'C': 'B#',
    'E': 'E#',
    'F': 'E3',
    'B': 'Cb'
  };

  Note = (function() {
    function Note(val, temp) {
      var _noteFromFreq, _noteFromName,
        _this = this;
      if (typeof window !== "undefined" && window !== null) {
        this._play = temp.play;
        this._pluck = temp.pluck;
      }
      this.rootFrequency = temp.rootFrequency();
      this.temperament = temp._temperament;
      _noteFromName = function(noteName) {
        var parsed;
        parsed = /([A-Ga-g])([b#]?)(\d+)/.exec(noteName);
        if ((parsed != null)) {
          _this.octave = parseInt(parsed[3], 10);
          _this.accidental = parsed[2];
          _this.letter = parsed[1].toUpperCase();
          if (_this.accidental != null) {
            _this.letter += _this.accidental;
          }
          _this.frequency = utils.normalize(_this.getFrequencyFromNoteLetter());
          return _this.name = val;
        } else {
          throw new TypeError('Note name "' + noteName + '" is not a valid argument');
        }
      };
      _noteFromFreq = function(freq) {
        if ((30000 > freq && freq > 0)) {
          _this.octave = Math.floor(Math.log(freq / _this.rootFrequency) / Math.log(2));
          _this.frequency = utils.normalize(freq);
          _this.letter = _this.getNoteLetterFromFrequency();
          _this.name = _this.letter + _this.octave.toString();
          return _this.accidental = _this.name.match(/[b#]/) != null ? _this.name.match(/[b#]/) : "";
        } else {
          throw new RangeError('Frequency "' + freq + '" is not valid');
        }
      };
      if (utils.type(val) === "string") {
        _noteFromName(val);
      }
      if (utils.type(val) === "number") {
        _noteFromFreq(val);
      }
      this.midiNote = Math.round(12 * Math.log(this.frequency / 440) / Math.log(2) + 69);
    }

    Note.prototype.getNoteArray = function(letter) {
      if (flatKeys.indexOf(letter) > -1) {
        return notesFlat;
      } else {
        return notesSharp;
      }
    };

    Note.prototype.getNoteLetterFromFrequency = function() {
      var baseFreq, noteArray, noteNumber;
      baseFreq = Math.log(this.frequency / this.referenceFrequency());
      noteNumber = Math.round(baseFreq / utils.stepRatio);
      if (noteNumber === 12) {
        this.octave += 1;
      }
      noteArray = this.getNoteArray(this.letter);
      return noteArray[noteNumber % 12];
    };

    Note.prototype.getFrequencyFromNoteLetter = function() {
      var noteArray, position, ratio;
      noteArray = this.getNoteArray(this.letter);
      position = noteArray.indexOf(this.letter);
      ratio = utils.ratioFromCents(temperaments[this.temperament][position]);
      return utils.normalize(ratio * this.referenceFrequency());
    };

    Note.prototype.referenceFrequency = function() {
      return this.rootFrequency * Math.pow(2, this.octave);
    };

    return Note;

  })();

  if (typeof window !== "undefined" && window !== null) {
    Note.prototype.play = function(length) {
      return this._play.call(this, length);
    };
    Note.prototype.pluck = function(length) {
      return this._pluck.call(this, length);
    };
  }

  intervals = ['U', 'm2', 'M2', 'm3', 'M3', 'P4', 'd5', 'P5', 'm6', 'M6', 'm7', 'M7', 'O'];

  intervals_full = ['unison', 'minor second', 'major second', 'minor third', 'major third', 'perfect fourth', 'diminished fifth', 'perfect fifth', 'minor sixth', 'major sixth', 'minor seventh', 'major seventh', 'octave'];

  Interval = (function(_super) {
    __extends(Interval, _super);

    function Interval(val, temp, direction, octave) {
      var _intervalNamefromNoteName, _noteFromInterval,
        _this = this;
      this.direction = direction != null ? direction : "up";
      this.tonic = temp.tonic;
      _noteFromInterval = function(val, octave) {
        var intervalNote, intervalNumber, intervalOctave, noteArray, position;
        _this.intervalName = val;
        position = intervals.indexOf(val);
        noteArray = _this.tonic.getNoteArray();
        console.log(octave);
        intervalOctave = octave;
        if (_this.direction === 'up') {
          intervalNumber = noteArray.indexOf(_this.tonic.letter) + position;
          if (intervalNumber >= 12) {
            intervalOctave += 1;
          }
        } else if (_this.direction === 'down') {
          intervalNumber = noteArray.indexOf(_this.tonic.letter) - position;
          if (intervalNumber < 0) {
            intervalOctave -= 1;
            intervalNumber += 12;
          }
        }
        return intervalNote = noteArray[intervalNumber % 12] + intervalOctave.toString();
      };
      _intervalNamefromNoteName = function() {
        var noteArray, offsetPosition, position, rootPosition, tonicNoteArray;
        tonicNoteArray = _this.getNoteArray.call(_this.tonic);
        noteArray = _this.getNoteArray();
        rootPosition = tonicNoteArray.indexOf(_this.tonic.letter);
        offsetPosition = noteArray.indexOf(_this.letter);
        _this.direction = 'down';
        position = (12 - offsetPosition + rootPosition) % 12;
        if (_this.tonic.octave < _this.octave || (_this.tonic.octave === _this.octave && offsetPosition > rootPosition)) {
          if (offsetPosition < rootPosition) {
            offsetPosition += 12;
          }
          position = offsetPosition - rootPosition;
          _this.direction = 'up';
        }
        return intervals[position];
      };
      if (intervals.indexOf(val) > -1) {
        val = _noteFromInterval(val, octave);
      }
      Interval.__super__.constructor.call(this, val, temp);
      if (!utils.type(this.intervalName)) {
        this.intervalName = _intervalNamefromNoteName();
      }
      if (this.tonic.name === this.name) {
        this.direction = '-';
      }
      this.frequencies = [this.tonic.frequency, this.frequency];
      this.names = [this.tonic.name, this.name];
      this.midiNotes = [this.tonic.midiNote, this.midiNote];
    }

    return Interval;

  })(Note);

  if (typeof window !== "undefined" && window !== null) {
    Interval.prototype.play = function(length) {
      this._play.call(this, length, 2);
      return this._play.call(this.tonic, length, 2);
    };
    Interval.prototype.pluck = function(length) {
      this._pluck.call(this, length, 2);
      return this._pluck.call(this.tonic, length, 2);
    };
  }

  Collection = (function() {
    function Collection(item, temp, collection) {
      var note, _collectionFromArray, _collectionFromName, _i, _len, _ref,
        _this = this;
      this.tonic = temp.tonic;
      this.notes = [];
      this.name = 'unknown';
      if (typeof window !== "undefined" && window !== null) {
        this._play = temp.play;
        this._pluck = temp.pluck;
      }
      _collectionFromName = function(item) {
        var interval, _i, _len, _ref, _results;
        if (collection[item]) {
          _this.name = item;
          _ref = collection[item];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            interval = _ref[_i];
            _results.push(_this.notes.push(new Interval(interval, temp)));
          }
          return _results;
        } else {
          throw new TypeError('Name "' + item + '" is not a valid argument');
        }
      };
      _collectionFromArray = function(item) {
        var i, interval, key, note, positions, value, _i, _len, _results;
        positions = [];
        for (i = _i = 0, _len = item.length; _i < _len; i = ++_i) {
          note = item[i];
          interval = new Interval(note, temp);
          positions.push(interval.intervalName);
          _this.notes.push(interval);
        }
        _results = [];
        for (key in collection) {
          value = collection[key];
          if (JSON.stringify(value) === JSON.stringify(positions)) {
            _this.name = key;
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      if (utils.type(item) === 'string') {
        _collectionFromName(item);
      }
      if (utils.type(item) === 'array') {
        _collectionFromArray(item);
      }
      this.frequencies = [this.tonic.frequency];
      this.names = [this.tonic.name];
      this.midiNotes = [this.tonic.midiNote];
      _ref = this.notes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        note = _ref[_i];
        this.frequencies.push(note.frequency);
        this.names.push(note.name);
        this.midiNotes.push(note.midiNote);
      }
    }

    return Collection;

  })();

  chords = {
    'maj': ['M3', 'P5'],
    'maj6': ['M3', 'P5', 'M6'],
    'maj7': ['M3', 'P5', 'M7'],
    'majb6': ['M3', 'P5', 'm6'],
    'majb7': ['M3', 'P5', 'm7'],
    'min6': ['m3', 'P5', 'm6'],
    'min7': ['m3', 'P5', 'm7'],
    'minM7': ['m3', 'P5', 'M7'],
    'min': ['m3', 'P5'],
    'aug': ['M3', 'm6'],
    'aug7': ['M3', 'm6', 'M7'],
    'dim': ['m3', 'd5'],
    'dim7': ['m3', 'd5', 'M6'],
    'sus4': ['P4', 'P5'],
    'sus2': ['M2', 'P5'],
    'dream': ['P4', 'd5', 'P5']
  };

  Chord = (function(_super) {
    __extends(Chord, _super);

    function Chord(chord, temp) {
      Chord.__super__.constructor.call(this, chord, temp, chords);
    }

    return Chord;

  })(Collection);

  if (typeof window !== "undefined" && window !== null) {
    Chord.prototype.play = function(length) {
      var note, _i, _len, _ref, _results,
        _this = this;
      this._play.call(this.tonic, length, this.notes.length + 1);
      _ref = this.notes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        note = _ref[_i];
        _results.push((function(note) {
          return _this._play.call(note, length, _this.notes.length + 1);
        })(note));
      }
      return _results;
    };
    Chord.prototype.pluck = function(length) {
      var note, _i, _len, _ref, _results,
        _this = this;
      this._pluck.call(this.tonic, length, this.notes.length + 1);
      _ref = this.notes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        note = _ref[_i];
        _results.push((function(note) {
          return _this._pluck.call(note, length, _this.notes.length + 1);
        })(note));
      }
      return _results;
    };
  }

  scales = {
    'Major': ['M2', 'M3', 'P4', 'P5', 'M6', 'M7', 'O'],
    'Minor': ['M2', 'm3', 'P4', 'P5', 'm6', 'm7', 'O'],
    'Chromatic': ['m2', 'M2', 'm3', 'M3', 'P4', 'd5', 'P5', 'm6', 'M6', 'm7', 'M7', 'O'],
    'Ionian': ['M2', 'M3', 'P4', 'P5', 'M6', 'M7', 'O'],
    'Dorian': ['M2', 'm3', 'P4', 'P5', 'M6', 'm7', 'O'],
    'Phrygian': ['m2', 'm3', 'P4', 'P5', 'm6', 'm7', 'O'],
    'Lydian': ['M2', 'M3', 'A4', 'P5', 'M6', 'M7', 'O'],
    'Mixolydian': ['M2', 'M3', 'P4', 'P5', 'M6', 'm7', 'O'],
    'Aeolian': ['M2', 'm3', 'P4', 'P5', 'm6', 'm7', 'O'],
    'Locrian': ['m2', 'm3', 'P4', 'd5', 'm6', 'm7', 'O'],
    'Prometheus': ['M2', 'M3', 'd5', 'M6', 'm7', 'O']
  };

  Scale = (function(_super) {
    __extends(Scale, _super);

    function Scale(scale, temp) {
      Scale.__super__.constructor.call(this, scale, temp, scales);
    }

    return Scale;

  })(Collection);

  if (typeof window !== "undefined" && window !== null) {
    Scale.prototype.play = function(length) {
      var i, note, _i, _len, _ref, _results,
        _this = this;
      if (length == null) {
        length = 1;
      }
      this._play.call(this.tonic, length, 3);
      _ref = this.notes;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        note = _ref[i];
        _results.push((function(note) {
          return setTimeout((function() {
            return _this._play.call(note, length, 3);
          }), length * 1000 / 2 * (i + 1));
        })(note));
      }
      return _results;
    };
    Scale.prototype.pluck = function(length) {
      var i, note, _i, _len, _ref, _results,
        _this = this;
      if (length == null) {
        length = 1;
      }
      this._pluck.call(this.tonic, length, 3);
      _ref = this.notes;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        note = _ref[i];
        _results.push((function(note) {
          return setTimeout((function() {
            return _this._pluck.call(note, length, 3);
          }), length * 1000 / 2 * (i + 1));
        })(note));
      }
      return _results;
    };
  }

  temperaments = {
    'Equal': [0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200],
    'Pythagorean': [0, 113.69, 203.91, 294.13, 407.82, 498.04, 611.73, 701.95, 815.64, 905.87, 996.09, 1109.78, 120],
    'Natural': [0, 111.74, 203.91, 315.64, 386.31, 498.05, 603, 702, 813.69, 884.36, 1017.6, 1088.27, 1200],
    '1/3 comma Meantone': [0, 63.50, 189.57, 315.64, 379.14, 505.21, 568.72, 694.79, 758.29, 884.36, 1010.43, 1073.93, 1200],
    '2/7 comma Meantone': [0, 70.67, 191.62, 312.57, 383.24, 504.19, 574.86, 695.81, 766.48, 887.43, 1008.38, 1079.05, 1200],
    '1/4 comma Meantone': [0, 76.05, 193.16, 310.26, 386.31, 503.42, 579.47, 696.58, 772.63, 889.74, 1006.84, 1082.89, 1200],
    '1/5 comma Meantone': [0, 83.58, 195.31, 307.04, 390.61, 502.35, 585.92, 697.65, 781.23, 892.96, 1004.69, 1088.27, 1200],
    '1/6 comma Meantone': [0, 88.59, 196.74, 304.89, 393.48, 501.63, 590.22, 698.37, 786.96, 895.11, 1003.26, 1091.85, 1200],
    '1/8 comma Meantone': [0, 94.87, 198.53, 302.20, 397.07, 500.73, 595.60, 699.27, 794.13, 897.80, 1001.47, 1096.33, 1200],
    'Ordinaire': [0, 86.81, 193.16, 296.09, 386.31, 503.42, 584.85, 696.58, 788.76, 889.74, 1005.22, 1082.89, 1200],
    'Werckmeister III': [0, 90.22, 192.18, 294.14, 390.23, 498.05, 588.27, 696.09, 792.18, 888.27, 996.09, 1092.18, 1200],
    'Kirnberger': [0, 91, 192, 296, 387, 498, 591, 696, 792, 890, 996, 1092, 1200],
    'Kirnberger III': [0, 90.18, 193.16, 294.13, 386.31, 498.04, 590.22, 696.58, 792.18, 889.74, 996.09, 1088.27, 1200],
    'Young': [0, 93.69, 195.91, 298.13, 391.82, 502.04, 591.73, 697.96, 796.18, 893.87, 1000.09, 1089.78, 1200]
  };

  temperaments['1/11 comma Meantone'] = temperaments['Equal'];

  temperaments['Salinas'] = temperaments['1/3 comma Meantone'];

  temperaments['Aaron'] = temperaments['1/4 comma Meantone'];

  temperaments['Silbermann'] = temperaments['1/5 comma Meantone'];

  Temper = (function() {
    function Temper(val, tuningFrequency, _temperament) {
      this.tuningFrequency = tuningFrequency != null ? tuningFrequency : 440;
      this._temperament = _temperament != null ? _temperament : 'Equal';
      if (val != null) {
        this.tonic = new Note(val, this);
      }
      this;
    }

    Temper.prototype.rootFrequency = function() {
      var ratio;
      ratio = utils.ratioFromCents(temperaments[this._temperament][9]);
      return this.tuningFrequency / Math.pow(2, 4) / ratio;
    };

    Temper.prototype.note = function(noteName) {
      if (noteName != null) {
        return this.tonic = new Note(noteName, this);
      } else {
        return this.tonic;
      }
    };

    Temper.prototype.temperament = function(temperament) {
      if (temperament != null) {
        if (temperaments[temperament]) {
          this._temperament = temperament;
          this.note(this.tonic.name);
          if (this._interval) {
            this.interval(this._interval.name);
          }
        }
        return this;
      } else {
        return this._temperament;
      }
    };

    Temper.prototype.interval = function(interval, direction, octave) {
      if (interval != null) {
        return this._interval = new Interval(interval, this, direction, octave);
      } else {
        return this._interval;
      }
    };

    Temper.prototype.scale = function(scale) {
      if (scale != null) {
        return this._scale = new Scale(scale, this);
      } else {
        return this._scale;
      }
    };

    Temper.prototype.chord = function(chord) {
      if (chord != null) {
        return this._chord = new Chord(chord, this);
      } else {
        return this._chord;
      }
    };

    return Temper;

  })();

  root = this;

  temper = function(val, tuningFrequency, temperament) {
    return new Temper(val, tuningFrequency, temperament);
  };

  temper.note = function(val) {
    return new Temper(val);
  };

  temper.tonic = function(val) {
    return new Temper(val);
  };

  temper.chords = function(val) {
    return utils.list.call(chords, val);
  };

  temper.intervals = function(val) {
    return utils.list.call(intervals, val, true);
  };

  temper.temperaments = function(val) {
    return utils.list.call(temperaments, val);
  };

  temper.centOffset = utils.centOffset;

  if (typeof exports !== "undefined") {
    module.exports = temper;
  } else {
    root["temper"] = temper;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    context = new AudioContext();
    Temper.prototype.play = function(length, numOfNotes) {
      var begin, end, osc, vol, volume;
      if (length == null) {
        length = 2;
      }
      if (numOfNotes == null) {
        numOfNotes = 1;
      }
      volume = 0.9 / numOfNotes;
      begin = context.currentTime;
      end = begin + length;
      osc = context.createOscillator();
      osc.type = 'sine';
      osc.frequency.value = this.frequency ? this.frequency : this.tonic.frequency;
      vol = context.createGain();
      vol.gain.setValueAtTime(0, begin);
      vol.gain.linearRampToValueAtTime(volume, end - (length * 0.5));
      vol.gain.linearRampToValueAtTime(0, end);
      osc.connect(vol);
      vol.connect(context.destination);
      osc.start(begin);
      return osc.stop(end);
    };
    Temper.prototype.pluck = function(length, numOfNotes) {
      var audioBuffer, begin, end, frequency, pluck, samples, vol, volume, _karplusStrong;
      if (length == null) {
        length = 2;
      }
      if (numOfNotes == null) {
        numOfNotes = 1;
      }
      volume = 0.9 / numOfNotes;
      begin = context.currentTime;
      end = begin + length;
      _karplusStrong = function(freq) {
        var amp, decay, i, j, noise, period, prevIndex, samples, _generateSample;
        noise = [];
        samples = new Float32Array(context.sampleRate);
        period = Math.floor(context.sampleRate / freq);
        i = 0;
        while (i < period) {
          noise[i] = 2 * Math.random() - 1;
          i++;
        }
        prevIndex = 0;
        _generateSample = function() {
          var index, sample;
          index = noise.shift();
          sample = (index + prevIndex) / 2;
          prevIndex = sample;
          noise.push(sample);
          return sample;
        };
        amp = (Math.random() * 0.5) + 0.4;
        j = 0;
        while (j < context.sampleRate) {
          samples[j] = _generateSample();
          decay = amp - (j / context.sampleRate) * amp;
          samples[j] = samples[j] * decay;
          j++;
        }
        return samples;
      };
      vol = context.createGain();
      pluck = context.createBufferSource();
      frequency = this.frequency ? this.frequency : this.tonic.frequency;
      samples = _karplusStrong(frequency);
      audioBuffer = context.createBuffer(1, samples.length, context.sampleRate);
      audioBuffer.getChannelData(0).set(samples);
      pluck.buffer = audioBuffer;
      pluck.connect(vol);
      vol.connect(context.destination);
      vol.gain.value = volume;
      pluck.start(begin);
      return pluck.stop(end);
    };
  }

}).call(this);
