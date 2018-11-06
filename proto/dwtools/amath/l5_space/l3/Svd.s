(function _Svd_s_() {

'use strict';

let _ = _global_.wTools;
let vector = _.vector;
let abs = Math.abs;
let min = Math.min;
let max = Math.max;
let pow = Math.pow;
let pi = Math.PI;
let sin = Math.sin;
let cos = Math.cos;
let sqrt = Math.sqrt;
let sqr = _.sqr;
let longSlice = Array.prototype.slice;

let Parent = null;
let Self = _global_.wSpace;

_.assert( _.objectIs( vector ) );
_.assert( _.routineIs( Self ),'wSpace is not defined, please include wSpace.s first' );


//

function isDiagonal()
{
  let self = this;

  _.assert( _.Space.is( self ) );

  let cols = self.length;
  let rows = self.atomsPerElement;

  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      debugger;
      if( j !== i && self.atomGet( [ i, j ]) !== 0 )
      return false
    }
  }

  return true;
}

//

function isUpperTriangle( accuracy )
{
  let self = this;

  _.assert( _.Space.is( self ) );

  if( !_.numberIs( accuracy ) || arguments.length === 0 )
  accuracy = 1E-5;

  let cols = self.length;
  let rows = self.atomsPerElement;

  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      debugger;
      if( i > j )
      {
        let point = self.atomGet([ i, j ]);
        if( 0 - accuracy > point || point > 0 + accuracy )
        {
          return false
        }
      }
    }
  }

  return true;
}

//

function isSymmetric( accuracy )
{
  let self = this;

  _.assert( _.Space.is( self ) );

  if( !_.numberIs( accuracy ) || arguments.length === 0 )
  accuracy = 1E-5;

  let cols = self.length;
  let rows = self.atomsPerElement;

  if( cols !== rows )
  {
    return false;
  }


  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      debugger;
      if( i > j )
      {
        let dif = self.atomGet([ i, j ]) - self.atomGet([ j, i ]);
        if( 0 - accuracy > dif || dif > 0 + accuracy )
        {
          return false
        }
      }
    }
  }

  return true;
}

//

function qrIteration( q, r )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  //_.assert( !isNaN( self.clone().invert().atomGet([ 0, 0 ]) ), 'Matrix must be invertible' )

  let cols = self.length;
  let rows = self.atomsPerElement;

  if( arguments.length === 0 )
  {
    var q = _.Space.makeIdentity( [ rows, cols ] );
    var r = _.Space.make([ rows, cols ]);
  }

  let a = self.clone();
  let loop = 0;
  q.copy( _.Space.makeIdentity( rows ) );


  while( a.isUpperTriangle() === false && loop < 1000 )
  {
    var qInt = _.Space.makeIdentity([ rows, cols ]);
    var rInt = _.Space.makeIdentity([ rows, cols ]);
    a.qrDecompositionHH( qInt, rInt );
    // Calculate transformation matrix
    q.mulLeft( qInt );

    a.mul2Matrices( rInt, qInt );

    loop = loop + 1;
  }

  q.copy( q );
  r.copy( a );

  if( loop === 1000 )
  {
    r.copy( rInt );
  }

  let eigenValues = _.vector.toArray( a.diagonalVectorGet() );
  eigenValues.sort( ( a, b ) => b - a );

  logger.log( 'EI',eigenValues)
  for( let i = 0; i < eigenValues.length; i++ )
  {
    let newValue = eigenValues[ i ];
    for( let j = 0; j < eigenValues.length; j++ )
    {
      let value = r.atomGet( [ j, j ] );

      if( newValue === value )
      {
        let oldColQ = q.colVectorGet( i ).clone();
        let oldValue = r.atomGet( [ i, i ] );

        q.colSet( i, q.colVectorGet( j ) );
        q.colSet( j, oldColQ );

        r.atomSet( [ i, i ], r.atomGet( [ j, j ] ) );
        r.atomSet( [ j, j ], oldValue );
      }
    }
  }

  return r.diagonalVectorGet();
}

//

function qrDecompositionGS( q, r )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  _.assert( _.Space.is( q ) );
  _.assert( _.Space.is( r ) );

  let cols = self.length;
  let rows = self.atomsPerElement;

  _.assert( !isNaN( self.clone().invert().atomGet([ 0, 0 ]) ), 'Matrix must be invertible' )

  let matrix = self.clone();
  q.copy( _.Space.makeIdentity( [ rows, cols ] ) );

  let qInt = _.Space.makeIdentity([ rows, cols ]);

  for( let i = 0; i < cols; i++ )
  {
    let col = matrix.colVectorGet( i );
    let sum = _.vector.from( _.array.makeArrayOfLengthZeroed( rows ) );
    for( let j = 0; j < i ; j ++ )
    {
      let dot = _.vector.dot( col, _.vector.from( qInt.colVectorGet( j ) ) );
      debugger;

      _.vector.addVectors( sum, _.vector.mulScalar( _.vector.from( qInt.colVectorGet( j ) ).clone(), - dot ) );
    }
    let e = _.vector.normalize( _.vector.addVectors( col.clone(), sum ) );
    qInt.colSet( i, e );
  }

  // Calculate R
  r.mul2Matrices( qInt.clone().transpose(), matrix );

  // Calculate transformation matrix
  q.mulLeft( qInt );
  let a = _.Space.make([ cols, rows ]);
}

//

function qrDecompositionHH( q, r )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  _.assert( _.Space.is( q ) );
  _.assert( _.Space.is( r ) );

  let cols = self.length;
  let rows = self.atomsPerElement;

  let matrix = self.clone();

  q.copy( _.Space.makeIdentity( rows ) );
  let identity = _.Space.makeIdentity( rows );

  // Calculate Q
  for( let j = 0; j < cols; j++ )
  {
    let u = _.vector.from( _.array.makeArrayOfLengthZeroed( rows ) );
    let e = identity.clone().colVectorGet( j );
    let col = matrix.clone().colVectorGet( j );

    for( let i = 0; i < j; i ++ )
    {
      col.eSet( i, 0 );
    }
    debugger;
    let c = 0;

    if( matrix.atomGet( [ j, j ] ) > 0 )
    {
      c = 1;
    }
    else
    {
      c = -1;
    }

    u = _.vector.addVectors( col, e.mulScalar( c*col.mag() ) ).normalize();

    debugger;
    let m = _.Space.make( [ rows, cols ] ).fromVectors( u, u );
    let h = m.addMatrix( identity, m.mulScalar( - 2 ) );
    q.mulLeft( h );

    matrix = _.Space.mul2Matrices( null, h, matrix );
  }

  r.copy( matrix );

  // Calculate R
  // r.mul2Matrices( h.clone().transpose(), matrix );
  let m = _.Space.mul2Matrices( null, q, r );
  let rb = _.Space.mul2Matrices( null, q.clone().transpose(), self )

  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      if( m.atomGet( [ i, j ] ) < self.atomGet( [ i, j ] ) - 1E-4 )
      {
        throw _.err( 'QR decomposition failed' );
      }

      if( m.atomGet( [ i, j ] ) > self.atomGet( [ i, j ] ) + 1E-4 )
      {
        throw _.err( 'QR decomposition failed' );
      }
    }
  }
}

//

function fromVectors( v1, v2 )
{
  _.assert( _.vectorIs( v1 ) );
  _.assert( _.vectorIs( v2 ) );
  _.assert( v1.length === v2.length );

  let matrix = _.Space.make( [ v1.length, v2.length ] );

  for( let i = 0; i < v1.length; i ++ )
  {
    for( let j = 0; j < v2.length; j ++ )
    {
      matrix.atomSet( [ i, j ], v1.eGet( i )*v2.eGet( j ) );
    }
  }

  return matrix;
}

//

function addMatrix( m1, m2 )
{
  _.assert( _.spaceIs( m1 ) );
  _.assert( _.spaceIs( m2 ) );

  let dims1 = _.Space.dimsOf( m1 ) ;
  let dims2 = _.Space.dimsOf( m2 ) ;
  _.assert( dims1[ 0 ] === dims2[ 0 ] );
  _.assert( dims1[ 1 ] === dims2[ 1 ] );

  let rows = dims1[ 0 ];
  let cols = dims1[ 1 ];

  let matrix = _.Space.make([ rows, cols ]);

  for( let i = 0; i < rows; i ++ )
  {
    for( let j = 0; j < cols; j ++ )
    {
      matrix.atomSet( [ i, j ], m1.atomGet( [ i, j ] ) + m2.atomGet( [ i, j ] ) );
    }
  }

  return matrix;
}

//

function svd( u, s, v )
{
  let self = this;
  _.assert( _.Space.is( self ) );
  _.assert( arguments.length === 3 );

  let dims = _.Space.dimsOf( self );
  let cols = dims[ 1 ];
  let rows = dims[ 0 ];
  let min = rows;
  if( cols < rows )
  min = cols;

  if( arguments[ 0 ] == null )
  var u = _.Space.make([ rows, rows ]);

  if( arguments[ 1 ] == null )
  var s = _.Space.make([ rows, cols ]);

  if( arguments[ 2 ] == null )
  var v = _.Space.make([ cols, cols ]);

  if( self.isSymmetric() === true )
  {
    let q =  _.Space.make( [ cols, rows ] );
    let r =  _.Space.make( [ cols, rows ] );
    let identity = _.Space.makeIdentity( [ cols, rows ] );
    self.qrIteration( q, r );

    let eigenValues = r.diagonalVectorGet();
    for( let i = 0; i < cols; i++ )
    {
      if( eigenValues.eGet( i ) >= 0 )
      {
        u.colSet( i, q.colVectorGet( i ) );
        s.colSet( i, identity.colVectorGet( i ).mulScalar( eigenValues.eGet( i ) ) );
        v.colSet( i, q.colVectorGet( i ) );
      }
      else if( eigenValues.eGet( i ) < 0 )
      {
        u.colSet( i, q.colVectorGet( i ).mulScalar( - 1 ) );
        s.colSet( i, identity.colVectorGet( i ).mulScalar( - eigenValues.eGet( i ) ) );
        v.colSet( i, q.colVectorGet( i ).mulScalar( - 1 ) );
      }
    }
  }
  else
  {
    let aaT = _.Space.mul2Matrices( null, self, self.clone().transpose() );
    let qAAT = _.Space.make( [ rows, rows ] );
    let rAAT = _.Space.make( [ rows, rows ] );

    aaT.qrIteration( qAAT, rAAT );
    let sd = _.Space.mul2Matrices( null, rAAT, qAAT.clone().transpose() )

    u.copy( qAAT );

    let aTa = _.Space.mul2Matrices( null, self.clone().transpose(), self );
    let qATA = _.Space.make( [ cols, cols ] );
    let rATA = _.Space.make( [ cols, cols ] );

    aTa.qrIteration( qATA, rATA );

    let sd1 = _.Space.mul2Matrices( null, rATA, qATA.clone().transpose() )

    v.copy( qATA );

    let eigenV = rATA.diagonalVectorGet();

    for( let i = 0; i < min; i++ )
    {
      if( eigenV.eGet( i ) !== 0 )
      {
        let col = u.colVectorGet( i ).slice();
        let m1 = _.Space.make( [ col.length, 1 ] ).copy( col );
        let m2 = _.Space.mul2Matrices( null, self.clone().transpose(), m1 );

        v.colSet( i, m2.colVectorGet( 0 ).mulScalar( 1 / eigenV.eGet( i ) ).normalize() );
      }
    }


    for( let i = 0; i < min; i++ )
    {
      s.atomSet( [ i, i ], Math.sqrt( Math.abs( rATA.atomGet( [ i, i ] ) ) ) );
    }
  }
}


// --
// relations
// --


let Extend =
{

  isDiagonal : isDiagonal,
  isUpperTriangle : isUpperTriangle,
  isSymmetric : isSymmetric,

  qrIteration : qrIteration,
  qrDecompositionGS : qrDecompositionGS,
  qrDecompositionHH : qrDecompositionHH,

  fromVectors : fromVectors,
  addMatrix : addMatrix,

  svd : svd,

}

_.classExtend( Self, Extend );

})();
