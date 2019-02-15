THIS REPO IS NO LONGER MAINTAINED. A NEW, COMPLETELY REWRITTEN, VERSION WILL BE RELEASED SOON>

---


# Temper.js
A lightweight music theory library for tuning the [web audio api](https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html).

temper.js' goal is to provide an easy way to convert pitch names to frequencies (and vice versa) in a variety of 12 step [temperaments](http://en.wikipedia.org/wiki/Musical_temperament). It also provides easy access to intervals, chords and scales for pitch comparisons to aid in researching the science of music.

## Installation & Simple Usage

First off, get **temper.js** into your webpage:  
```html
bower install temper  
<script src='bower_componentes/temper/temper.min.js'></script>
```

or into your node app:

```javascript
npm install temper
var temper = require('temper.js');
```
Next, create a temper object:

```javascript
var a440 = temper('A4');          // creates an object with "A4" as the tonic
a440.interval('m3');              // adds an interval (minor 3rd) to the object
a440.interval().name;             // returns "C5"
a440.interval().frequency;        // returns 523.251
a440.temperament('Pythagorean');  // changes the object's tuning system
a440.interval().frequency;        // returns 521.48
a440.scale('Whole Tone');         // adds a scale (Whole Tone) to the object
a440.scale().midiNotes;           // returns [69, 71, 73, 75, 77, 79, 81]
a440.scale().names;               // returns ["A4", "B4", "C#5", "D#5", "F5", "G5", "A5"]
```


## Documentation
##### Table of Contents


+ [Notes](#note)
+ [Intervals](#intervals)
+ [Chords & Scales](#chords)
+ [Temperaments](#temperamants)
+ [Temper](#temper)
+ [Helper Functions]()

__________________________________

### Notes / Tonics
##### Constructor
_When called with arguments, creates or changes a temper object's tonic (base note)._
```javascript
temper.note([noteName or frequency])
temper.tonic([noteName or frequency])
```

The argument is the note wanted for the tonic of the temper object.  
+ `noteName` **String**  
Made up of a note name and an octave, e.g. `'A4'` or `'E#5'`

+ `frequency` **Number**  
The desired frequency in hertz, e.g. `440` or `261.252`

##### Attributes
_When accessed without arguments, provides access to the tonic's attributes._
```javascript
temper.note().attributeName
temper.tonic().attributeName
```

+ `name` returns **String**  
The full name of the note (letter + accidental + octave)  

+ `frequency` returns **Number**  
The frequency of the note (in hertz) in the current temperament

+ `octave` returns **Number**  
The octave of the note  

+ `letter` returns **String**
The note's name without the octave

+ `accidental` returns **String**  
The note's sharp (#) or flat (b) modifier (if any)

+ `midiNote` returns **Number**.  
The standard midi note

##### Methods
_These can be called on a newly constructed or pre-existing temper object with chaining._
```javascript
temper.note().play()
temper.tonic().play()
```
+ `play([length])`  
Simple 'synth' sound playing back the current tonic. Takes a single, optional argument of length (in seconds).

+ `pluck([length])`  
Simple 'string pluck' sound playing back the current tonic. Takes a single, optional argument of length (in seconds).


##### Examples
```javascript
var a440 = temper.note(440);
```

______

### Intervals

##### Constructor
_When called with arguments, creates or changes a temper object's interval above or below the tonic._  
_Requires a tonic to be set._
```javascript
temper.interval([noteName or frequency or intervalName], [direction], [octaveOffset])
```

The first argument is the note wanted for the interval of the temper object.  
+ `noteName` **String**  
Made up of a note name and an octave, e.g. `'A5'` or `'Gb7'`

+ `frequency` **Number**  
The interval's desired frequency in hertz, e.g. `880` or `123.456`

+ `intervalName` **String**  
A named interval size, e.g. `'P5'` or `'m2'`  
[Show a list](#temper_interval) of available options

+ `direction` **String**   Either `'up'` or `'down'`  
When used in conjunction with an `intervalName`, tells whether to make the interval above or below the tonic

+ `octaveOffset` **Number**  
How many octaves the interval should span, defaults to `0`

##### Attributes
_When accessed without arguments, provides access to the intervals's attributes._
```javascript
temper.interval().attributeName
```

+ `name` returns **String**  
The full name of the interval (letter + accidental + octave)  

+ `frequency` returns **Number**  
The frequency of the note (in hertz) in the current temperament

+ `octave` returns **Number**  
The octave of the note  

+ `letter` returns **String**
The note's name without the octave

+ `accidental` returns **String**  
The note's sharp (#) or flat (b) modifier (if any)

+ `midiNote` returns **Number**.  
The standard midi note

+ `intervalName` returns **String**  
The name of the interval size

+ `direction` returns **String**  
The direction, `'up'` or '`down`', of the interval

+ `frequencies` returns **Array**  
The interval and the tonic's frequencies

+ `midiNotes` returns **Array**  
The interval and the tonic's standard midi notes

+ `names` returns **Array**  
The interval and the tonic's note names


##### Methods
_These can be called on a newly constructed or pre-existing temper object with chaining._
```javascript
temper.note().play()
temper.tonic().play()
```
+ `play([length])`  
Simple 'synth' sound playing back the current tonic. Takes a single, optional argument of length (in seconds).

+ `pluck([length])`  
Simple 'string pluck' sound playing back the current tonic. Takes a single, optional argument of length (in seconds).


##### Examples
```javascript
var a440 = temper.note(440);
```

### Chords & Scales


### Temperaments

### Temper & Helper Functions
Calling `temper()` as a method provides a shorthand for creating a tonic,
with some additional, advanced functionality.
##### Constructor
_When called with arguments, creates a temper object and sets it's tonic._  

```javascript
temper(noteName or frequency, [tuningFrequency], [temperament])
```

The first argument is the note wanted for the tonic of the temper object.  
+ `noteName` **String**  
Made up of a note name and an octave, e.g. `'A4'` or `'E#5'`

+ `frequency` **Number**  
The desired frequency in hertz, e.g. `440` or `261.252`

Optional arguments include:  
+ `tuningFrequency` **Number**  
The pitch the system tunes to, defaults to `440`

+ `temperament` **String**  
The name of the desired tuning system[*](), defaults to `'Equal'`

##### Attributes
same as [`temper.note()`](#note)

##### Methods
In addition to `play()` and `pluck()` that are found on [`temper.note()`](#note),
`temper` also has the following helper functions that are not accessed through the constructor.

+ `temper.intervals([interval])` returns **Array**
+ `temper.chords([chord])` returns **Array**
+ `temper.scales([scale])` returns **Array**
+ `temper.temperaments([temperament])` returns **Array**

These all can be called with or with out an argument. When called without they will list out the available properties of their namesake.
When called with an argument, they return the value of the named property.


##### Example
```javascript
var a440 = temper.chords(440);
```

______


## Considerations

#### Browser support
Since the purpose temper of is to provide helpers for the web audio api,
I made no effort to support legacy browsers.
And while temper's main JavaScript functionality will work in any modern browser,
only those that support the web audio api will be able to use playback. Sorry IE. [Browser Compatibility Table](https://developer.mozilla.org/en-US/docs/Web_Audio_API#Browser_compatibility)

#### Midi Notes
Currently

#### Note Naming Scheme
temper.js makes use of **Scientific Pitch Notation** where octaves begin with C and where C4 is middle C.


## Roadmap
+ Precision MIDI values for non-standard tunings
+ Better (interactive) Documentation
+ Better support for intervals greater than an octave
+ Better support for enharmonic equivalents
+ Figured Bass / Chord inversion support
+ Integration with [Vexflow](https://github.com/0xfe/vexflow)

## Licence
MIT
