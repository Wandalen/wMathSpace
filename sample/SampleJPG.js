if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');

var _ = wTools;

 // Manipulates local drive

debugger;

let jpgPath = 'C:/Users/pabel/Desktop/Trabajo/sample.jpg'
let s = _.Space.make([ 3, 3 ]);
s.huffmanDecoder( jpgPath )

let jpgPath1 = 'C:/Users/pabel/Desktop/Trabajo/ask.jpg'
let s1 = _.Space.make([ 3, 3 ]);
s1.huffmanDecoder( jpgPath1 )
let jpgPath2 = 'C:/Users/pabel/Pictures/black.jpg'
let s2 = _.Space.make([ 3, 3 ]);
s2.huffmanDecoder( jpgPath2 )
