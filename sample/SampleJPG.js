if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');

var _ = wTools;

 // Decode Jpg
let jpgPath = __dirname + '/../assets/Images/JPG/mini8.jpg';
let s = _.Space.make([ 3, 3 ]);
let data = s.getData( jpgPath );
debugger;
let result = s.decodeJPG( data );

logger.log( 'Decoded from', data.length, 'jpg values to', 0.75 * result.length, 'rgb values.')
logger.log( result );

logger.log( '' );
logger.log( 'Next Image :' );
logger.log( '' );

let jpgPath2 = __dirname + '/../assets/Images/JPG/mini96.jpg';
let s2 = _.Space.make([ 3, 3 ]);
let data2 = s2.getData( jpgPath2 );
debugger;
let result2 = s2.decodeJPG( data2 );

logger.log( 'Decoded from', data2.length, 'jpg values to', 0.75 * result2.length, 'rgb values.')
