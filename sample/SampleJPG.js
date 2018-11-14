if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');

var _ = wTools;

 // Decode Jpg
debugger;

let jpgPath = 'C:/Users/pabel/Desktop/Trabajo/Kos/JPEGdecoder/Images/lions.jpg'
let s = _.Space.make([ 3, 3 ]);
let data = s.getData( jpgPath );  // Get image data
// s.decodeJPG( data );  // Decode data

logger.log('')
logger.log('Next Image')
logger.log('')
let jpgPath1 = 'C:/Users/pabel/Desktop/Trabajo/Kos/JPEGdecoder/Images/fuego.jpg'
let s1 = _.Space.make([ 3, 3 ]);
let data1 = s1.getData( jpgPath1 );
// s1.decodeJPG( data1 );


logger.log('')
logger.log('Next Image')
logger.log('')
let jpgPath2 = 'C:/Users/pabel/Desktop/Trabajo/Kos/JPEGdecoder/Images/mini8.jpg'
let s2 = _.Space.make([ 3, 3 ]);
let data2 = s2.getData( jpgPath2 );
let result = s2.decodeJPG( data2 );

logger.log( result );
