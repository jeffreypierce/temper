var temper = require('../temper.js');

var a = temper(440).scale('Major');
console.log(a.frequencies);

var b = temper(440).chord('maj');
console.log(b.midiNotes);

var i = temper(440).interval('P5', 'up', 8);
console.log(i);

