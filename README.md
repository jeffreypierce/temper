# Temper.js
A lightweight music theory library for tuning the [web audio api](https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html)

## Installation & Simple Usage

First off, get **temper.js** into your webpage:  
  
    bower install temper:  
    <script src='bower_componentes/temper/temper.min.js'></script>


or into your node app:

    npm install temper 
    var temper = require('temper.js');


Next, create a temper object:

    var a440 = temper('A4');          // creates an object with "A4" as the tonic
    a440.interval('m3');              // adds an interval (minor 3rd) to the object
    a440.interval().name;             // returns "C5"
    a440.interval().frequency;        // returns 523.251
    
    a440.temperament('Pythagorean');  // changes the object's tuning system
    a440.interval().frequency;        // returns 521.48

    a440.scale('Whole Tone');         // adds a scale (Whole Tone) to the object
    a440.scale().midiNotes;           // returns [69, 71, 73, 75, 77, 79, 81]
    a440.scale().names;               // returns ["A4", "B4", "C#5", "D#5", "F5", "G5", "A5"]



## Documentation

+ temper
+ intervals
+ chords
+ scales
+ temperaments
+ helper functions

#### temper  
`temper(noteName or frequency, [tuningFrequency], [temperament])`

#### .note()




#### .interval() 

#### .chord()

#### .scale()

#### .temperaments()

#### helper functions


## Considerations

## Roadmap
+ Precision MIDI values for non-standard tunings
+ Chord Inverstion / Figured Bass
+ Better Documentation
+ Fugired Bass / Chord invertion support

## Licence
MIT