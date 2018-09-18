
if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');


var _ = wTools;

var matrix =  _.Space.make( [ 2, 3 ] ).copy
([
  3, 2, 2,
  2, 3, -2,
]);

var u = _.Space.make( [ 2, 2 ] );
var s = _.Space.make( [ 2, 3 ] );
var v = _.Space.make( [ 3, 3 ] );

matrix.svd( u, s, v );
//logger.log( 'Final S', s );
//logger.log( 'Final V', v );
logger.log( 'Final U' );
for( var i = 0; i < 2; i++ )
{
  let row = u.rowVectorGet( i );
  logger.log( row.eGet( 0 ), row.eGet( 1 ) )
}

logger.log( 'Final S' );
for( var i = 0; i < 2; i ++ )
{
  let row = s.rowVectorGet( i );
  logger.log( row.eGet( 0 ), row.eGet( 1 ), row.eGet( 2 ))
}

logger.log( 'Final V' );
for( var i = 0; i < 3; i ++ )
{
  let row = v.rowVectorGet( i );
  logger.log( row.eGet( 0 ), row.eGet( 1 ), row.eGet( 2 ))
}

let iss = _.Space.mul2Matrices( null, s, v.clone().transpose())
logger.log('Matrix',  _.Space.mul2Matrices( null, u, iss ) )
