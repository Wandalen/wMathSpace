
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

var matrix =  _.Space.make( [ 4, 2 ] ).copy
([
  2, 4,
  1, 3,
  0, 0,
  0, 0
]);

matrix.svd();
