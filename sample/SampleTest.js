
if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');


var _ = wTools;

// Manipulates local drive
var provider = _.FileProvider.HardDrive();

debugger;
var data = provider.fileRead
({
  filePath: 'c:/users/pabel/pictures/black.jpg',
  sync : 1,
  encoding : 'buffer.bytes'
});

debugger;
for( var i = 0; i < 67 ; i++ )
{
//  console.log( data[ i ], data[ i + 1 ], data[ i + 2 ], data[ i + 3 ], data[ i + 4 ], data[ i + 5 ], );
}

let matrix = _.Space.make([ 2, 2 ]).copy([
  8, 7,
  1, 2
]);

let q = matrix.qR();

logger.log('result', q )
