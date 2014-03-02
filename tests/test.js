var temper = require('../temper.js');

var a = temper(440).scale('Major');
console.log(a.frequencies);

var b = temper(440).chord('maj');
console.log(b.midiNotes);

var inter = temper(440).interval('P5', 'up', 4);
console.log(i);

var chord = temper(440).chord(['M3, up, 1', 'P5, up, 2']);
console.log(chord);
console.log(chord.names);
