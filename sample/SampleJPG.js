if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');

var _ = wTools;

 // Manipulates local drive

let matrix = _.Space.makeSquare([ 1,2,3,4 ]);
logger.log( matrix )
logger.log( matrix.isDiagonal( ) );
logger.log( matrix.byteToHex( '011' ) );
debugger;

let jpgPath = 'C:/Users/pabel/Desktop/Trabajo/Kos/JPEGdecoder/Images/lions.jpg'
let s = _.Space.make([ 3, 3 ]);
// s.decodeJPG( jpgPath );

logger.log('')
logger.log('Next Image')
logger.log('')
let jpgPath1 = 'C:/Users/pabel/Desktop/Trabajo/Kos/JPEGdecoder/Images/fuego.jpg'
let s1 = _.Space.make([ 3, 3 ]);
// s1.decodeJPG( jpgPath1 );


logger.log('')
logger.log('Next Image')
logger.log('')
let jpgPath2 = 'C:/Users/pabel/Desktop/Trabajo/Kos/JPEGdecoder/Images/mini8.jpg'
let s2 = _.Space.make([ 3, 3 ]);
let data = s2.getData( jpgPath2 );
let result = s2.decodeJPG( data );

logger.log( result );
