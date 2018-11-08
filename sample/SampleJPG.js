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

//let result = s2.decodeJPG( jpgPath2 );

//logger.log( result );
logger.log( 'HERE ')

var space = _.Space.make([ 3,3 ]);
var components = new Map();
components.set( 'numOfComponents', 1 );
components.set( 'C1Dc', 0 );
components.set( 'C1Ac', 0 );

var frameData = new Map();
frameData.set( 'C1V', 1 );
frameData.set( 'C1H', 1 );

var hfTables = new Map();
hfTables.set( 'Table1start', undefined )
hfTables.set( 'Table1end', undefined )
hfTables.set( 'Table1AcDc', 0 )
hfTables.set( 'Table1ID', 0 )
hfTables.set( 'Table1Codes', [ '00', '010', '011', '100', '101', '1110'] )
hfTables.set( 'Table1Values', [ 0, 1, 2, 3, 4, 5 ] )
hfTables.set( 'Table2start', undefined )
hfTables.set( 'Table2end', undefined )
hfTables.set( 'Table2AcDc', 1 )
hfTables.set( 'Table2ID', 0 )
hfTables.set( 'Table2Codes', [ '00', '01', '100', '1010', '1011', '1100' ] )
hfTables.set( 'Table2Values', [ 0, 1, 2, 3, 4, 20 ] )

var imageS = '01110101011110011110010111001100'
space.decodeHuffman( components, frameData, hfTables, imageS, 0 );

logger.log( components.get( 'C1-11' ) );
