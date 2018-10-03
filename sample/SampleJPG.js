if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');

var _ = wTools;

 // Manipulates local drive

debugger;

let jpgPath = 'C:/Users/pabel/Desktop/Trabajo/lions.jpg'
let s = _.Space.make([ 3, 3 ]);
//s.huffmanDecoder( jpgPath )

logger.log('')
logger.log('Next Image')
logger.log('')
let jpgPath1 = 'C:/Users/pabel/Desktop/Trabajo/fuego.jpg'
let s1 = _.Space.make([ 3, 3 ]);
// s1.huffmanDecoder( jpgPath1 )


logger.log('')
logger.log('Next Image')
logger.log('')
let jpgPath2 = 'C:/Users/pabel/Desktop/Trabajo/cara.jpg'
let s2 = _.Space.make([ 3, 3 ]);
s2.huffmanDecoder( jpgPath2 )
