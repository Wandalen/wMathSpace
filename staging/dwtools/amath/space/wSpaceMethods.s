(function _wSpaceMethods_s_() {

'use strict';

var _ = _global_.wTools;
var vector = _.vector;
var abs = Math.abs;
var min = Math.min;
var max = Math.max;
var pow = Math.pow;
var pi = Math.PI;
var sin = Math.sin;
var cos = Math.cos;
var sqrt = Math.sqrt;
var sqr = _.sqr;
var longSlice = Array.prototype.slice;

var Parent = null;
var Self = _global_.wSpace;

_.assert( _.objectIs( vector ) );
_.assert( _.routineIs( Self ),'wSpace is not defined, please include wSpace.s first' );

// --
// make
// --

function make( dims )
{
  var proto = this ? this.Self.prototype : Self.prototype;

  _.assert( !this.instanceIs() );
  _.assert( _.longIs( dims ) || _.numberIs( dims ) );
  _.assert( arguments.length === 1,'make expects single argument array (-dims-)' );

  if( _.numberIs( dims ) )
  dims = [ dims,dims ];

  var lengthFlat = proto.atomsPerSpaceForDimensions( dims );
  var strides = proto.stridesForDimensions( dims,0 );
  var buffer = proto.array.makeArrayOfLength( lengthFlat );
  var result = new proto.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    /*strides : strides,*/
  });

  _.assert( _.arrayIdentical( strides,result._stridesEffective ) );

  return result;
}

//

function makeSquare( buffer )
{
  var proto = this ? this.Self.prototype : Self.prototype;

  var length = buffer;
  if( _.longIs( buffer ) )
  length = Math.sqrt( buffer.length );

  _.assert( !this.instanceIs() );
  _.assert( _.prototypeIs( this ) || _.constructorIs( this ) );
  _.assert( _.longIs( buffer ) || _.numberIs( buffer ) );
  _.assert( _.numberIsInt( length ),'makeSquare expects square buffer' );
  _.assert( arguments.length === 1, 'expects single argument' );

  var dims = [ length,length ];
  var atomsPerSpace = this.atomsPerSpaceForDimensions( dims );

  var inputTransposing = atomsPerSpace > 0 ? 1 : 0;
  if( _.numberIs( buffer ) )
  {
    inputTransposing = 0;
    buffer = this.array.makeArrayOfLength( atomsPerSpace );
  }
  else
  {
    buffer = proto.constructor._bufferFrom( buffer );
  }

  var result = new proto.constructor
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : inputTransposing,
  });

  return result;
}

//

function makeZero( dims )
{
  var proto = this ? this.Self.prototype : Self.prototype;

  _.assert( !this.instanceIs() );
  _.assert( _.longIs( dims ) || _.numberIs( dims ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.numberIs( dims ) )
  dims = [ dims,dims ];

  var lengthFlat = proto.atomsPerSpaceForDimensions( dims );
  var strides = proto.stridesForDimensions( dims,0 );
  var buffer = proto.array.makeArrayOfLengthZeroed( lengthFlat );
  var result = new proto.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    /*strides : strides,*/
  });

  _.assert( _.arrayIdentical( strides,result._stridesEffective ) );

  return result;
}

//

function makeIdentity( dims )
{
  var proto = this ? this.Self.prototype : Self.prototype;

  _.assert( !this.instanceIs() );
  _.assert( _.longIs( dims ) || _.numberIs( dims ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.numberIs( dims ) )
  dims = [ dims,dims ];

  var lengthFlat = proto.atomsPerSpaceForDimensions( dims );
  var strides = proto.stridesForDimensions( dims,0 );
  var buffer = proto.array.makeArrayOfLengthZeroed( lengthFlat );
  var result = new proto.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    /*strides : strides,*/
  });

  result.diagonalSet( 1 );

  _.assert( _.arrayIdentical( strides,result._stridesEffective ) );

  return result;
}

//

function makeIdentity2( src )
{
  var proto = this ? this.Self.prototype : Self.prototype;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  var result = proto.makeIdentity( 2 );

  if( src )
  result.copy( src );

  return result;
}

//

function makeIdentity3( src )
{
  var proto = this ? this.Self.prototype : Self.prototype;

_.assert( arguments.length === 0 || arguments.length === 1 );

  var result = proto.makeIdentity( 3 );

  if( src )
  result.copy( src );

  return result;
}

//

function makeIdentity4( src )
{
  var proto = this ? this.Self.prototype : Self.prototype;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  var result = proto.makeIdentity( 4 );

  if( src )
  result.copy( src );

  return result;
}

//

function makeDiagonal( diagonal )
{

  _.assert( !this.instanceIs() );
  _.assert( _.prototypeIs( this ) || _.constructorIs( this ) );
  _.assert( _.arrayIs( diagonal ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  /* */

  var length = diagonal.length;
  var dims = [ length,length ];
  var atomsPerSpace = this.atomsPerSpaceForDimensions( dims );
  var buffer = this.array.makeArrayOfLengthZeroed( atomsPerSpace );
  var result = new this.Self
  ({
    buffer : buffer,
    dims : dims,
    inputTransposing : 0,
    // strides : [ 1,length ],
  });

  result.diagonalSet( diagonal );

  return result;
}

//

function makeSimilar( m , dims )
{
  var proto = this;
  var result;

  if( proto.instanceIs() )
  {
    _.assert( arguments.length === 0 || arguments.length === 1 );
    return proto.Self.makeSimilar( proto , arguments[ 0 ] );
  }

  if( dims === undefined )
  dims = proto.dimsOf( m );

  /* */

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.arrayIs( dims ) && dims.length === 2 );

  /* */

  if( m instanceof Self )
  {

    var atomsPerSpace = Self.atomsPerSpaceForDimensions( dims );
    var buffer = _.longMakeSimilarZeroed( m.buffer,atomsPerSpace );
    /* could possibly be not zeroed */

    result = new m.constructor
    ({
      buffer : buffer,
      dims : dims,
      inputTransposing : 0,
    });

  }
  else if( _.longIs( m ) )
  {

    _.assert( dims[ 1 ] === 1 );
    result = _.longMakeSimilar( m, dims[ 0 ] );

  }
  else if( _.vectorIs( m ) )
  {

    _.assert( dims[ 1 ] === 1 );
    result = m.makeSimilar( dims[ 0 ] );

  }
  else _.assert( 0,'unexpected type of container',_.strTypeOf( m ) );

  return result;
}

//

function makeLine( o )
{
  var proto = this ? this.Self.prototype : Self.prototype;
  var strides = null;
  var offset = 0;
  var length = ( _.longIs( o.buffer ) || _.vectorIs( o.buffer ) ) ? o.buffer.length : o.buffer;
  var dims = null;

  _.assert( !this.instanceIs() );
  _.assert( _.spaceIs( o.buffer ) || _.vectorIs( o.buffer ) || _.arrayIs( o.buffer ) || _.bufferTypedIs( o.buffer ) || _.numberIs( o.buffer ) );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( makeLine,o );

  /* */

  if( _.spaceIs( o.buffer ) )
  {
    _.assert( o.buffer.dims.length === 2 );
    if( o.dimension === 0 )
    _.assert( o.buffer.dims[ 1 ] === 1 );
    else if( o.dimension === 1 )
    _.assert( o.buffer.dims[ 0 ] === 1 );

    if( !o.zeroing )
    {
      return o.buffer;
    }
    else
    {
      o.buffer = o.buffer.dims[ o.dimension ];
      length = o.buffer;
    }
  }

  /* */

  if( o.zeroing )
  {
    o.buffer = length;
  }

  if( _.vectorIs( o.buffer ) )
  {
    length = o.buffer.length;
    o.buffer = proto._bufferFrom( o.buffer );
  }

  if( _.vectorIs( o.buffer ) )
  {

    offset = o.buffer.offset;
    length = o.buffer.length;

    if( o.buffer.stride !== 1 )
    {
      if( o.dimension === 0 )
      strides = [ o.buffer.stride,o.buffer.stride ];
      else
      strides = [ o.buffer.stride,o.buffer.stride ];
    }

    o.buffer = o.buffer._vectorBuffer;

  }
  else if( _.numberIs( o.buffer ) )
  o.buffer = o.zeroing ? this.array.makeArrayOfLengthZeroed( length ) : this.array.makeArrayOfLength( length );
  else if( o.zeroing )
  o.buffer = this.array.makeArrayOfLengthZeroed( length )
  else
  o.buffer = proto.constructor._bufferFrom( o.buffer );

  /* dims */

  if( o.dimension === 0 )
  {
    dims = [ length,1 ];
  }
  else if( o.dimension === 1 )
  {
    dims = [ 1,length ];
  }
  else _.assert( 0,'bad dimension',o.dimension );

  /* */

  var result = new proto.constructor
  ({
    buffer : o.buffer,
    dims : dims,
    inputTransposing : 0,
    strides : strides,
    offset : offset,
  });

  return result;
}

makeLine.defaults =
{
  buffer : null,
  dimension : -1,
  zeroing : 1,
}

//

function makeCol( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 0,
    dimension : 0,
  });
}

//

function makeColZeroed( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 1,
    dimension : 0,
  });
}

//

function makeRow( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 0,
    dimension : 1,
  });
}

//

function makeRowZeroed( buffer )
{
  return this.makeLine
  ({
    buffer : buffer,
    zeroing : 1,
    dimension : 1,
  });
}

// --
// converter
// --

function convertToClass( cls,src )
{
  var self = this;

  _.assert( !_.instanceIs( this ) );
  _.assert( _.constructorIs( cls ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( src.constructor === cls )
  return src;

  if( _.spaceIs( src ) )
  {

    if( _.subclassOf( cls, src.Self ) )
    {
      _.assert( src.Self === cls,'not tested' );
      return src;
    }

    _.assert( src.dims.length === 2 );
    _.assert( src.dims[ 1 ] === 1 );

    var result, array;
    var atomsPerSpace = src.atomsPerSpace;

    if( _.constructorLikeArray( cls ) )
    {
      result = new cls( atomsPerSpace );
      array = result;
    }
    else if( _.constructorIsVector( cls ) )
    {
      debugger;
      array = new src.buffer.constructor( atomsPerSpace );
      result = vector.fromArray( array );
    }
    else _.assert( 0,'unknown class (-cls-)',cls.name );

    for( var i = 0 ; i < result.length ; i += 1 )
    array[ i ] = src.atomGet([ i,0 ]);

  }
  else
  {

    var atomsPerSpace = src.length;
    src = vector.from( src );

    if( _.constructorIsSpace( cls ) )
    {
      var array = new src._vectorBuffer.constructor( atomsPerSpace );
      result = new cls
      ({
        dims : [ src.length,1 ],
        buffer : array,
        inputTransposing : 0,
      });
      for( var i = 0 ; i < src.length ; i += 1 )
      result.atomSet( [ i,0 ],src.eGet( i ) );
    }
    else if( _.constructorLikeArray( cls ) )
    {
      result = new cls( atomsPerSpace );
      for( var i = 0 ; i < src.length ; i += 1 )
      result[ i ] = src.eGet( i );
    }
    else if( _.constructorIsVector( cls ) )
    {
      var array = new src._vectorBuffer.constructor( atomsPerSpace );
      result = vector.fromArray( array );
      for( var i = 0 ; i < src.length ; i += 1 )
      array[ i ] = src.eGet( i );
    }
    else _.assert( 0,'unknown class (-cls-)',cls.name );

  }

  return result;
}

//

function fromVector( src )
{
  var result;

  _.assert( !this.instanceIs() );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.vectorIs( src ) )
  {
    result = new this.Self
    ({
      buffer : src._vectorBuffer,
      dims : [ src.length,1 ],
      strides : src.stride > 1 ? [ src.stride,1 ] : undefined,
      inputTransposing : 0,
    });
  }
  else if( _.arrayIs( src ) )
  {
    result = new this.Self
    ({
      buffer : src,
      dims : [ src.length,1 ],
      inputTransposing : 0,
    });
  }
  else _.assert( 0,'cant convert',_.strTypeOf( src ),'to Space' );

  return result;
}

//

function fromScalar( scalar,dims )
{

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.numberIs( scalar );

  var result = new this.Self
  ({
    buffer : this.array.arrayFromCoercing( _.dup( scalar,this.atomsPerSpaceForDimensions( dims ) ) ),
    dims : dims,
    inputTransposing : 0,
  });

  return result;
}

//

function fromScalarForReading( scalar,dims )
{

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.numberIs( scalar );

  var buffer = this.array.makeArrayOfLength( 1 );
  buffer[ 0 ] = scalar;

  var result = new this.Self
  ({
    buffer : buffer,
    dims : dims,
    strides : _.dup( 0,dims.length ),
  });

  return result;
}

//

function from( src,dims )
{
  var result;

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) || dims == undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( src === null )
  {
    _.assert( _.arrayIs( dims ) );
    result = this.makeZero( dims );
  }
  else if( src instanceof Self )
  {
    result = src;
  }
  else if( _.numberIs( src ) )
  {
    _.assert( _.arrayIs( dims ) );
    result = this.fromScalar( src,dims );
  }
  else
  {
    result = this.fromVector( src );
  }

  _.assert( !dims || result.hasShape( dims ) );

  return result;
}

//

function fromForReading( src,dims )
{
  var result;

  _.assert( !this.instanceIs() );
  _.assert( _.arrayIs( dims ) || dims == undefined );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( src instanceof Self )
  {
    result = src;
  }
  else if( _.numberIs( src ) )
  {
    _.assert( _.arrayIs( dims ) );
    result = this.fromScalarForReading( src,dims );
  }
  else
  {
    var result = this.fromVector( src );
  }

  _.assert( !dims || result.hasShape( dims ) );

  return result;
}

//

function fromTransformations( position, quaternion, scale )
{
  var self = this;

  _.assert( arguments.length === 3, 'expects exactly three argument' );

  self.fromQuat( quaternion );
  self.scaleApply( scale );
  self.positionSet( position );

  return self;
}

//

function fromQuat( q )
{
  var self = this;

  var q = _.vector.from( q );
  var x = q.eGet( 0 );
  var y = q.eGet( 1 );
  var z = q.eGet( 2 );
  var w = q.eGet( 3 );

  _.assert( self.atomsPerElement >= 3 );
  _.assert( self.length >= 3 );
  _.assert( q.length === 4 );
  _.assert( arguments.length === 1, 'expects single argument' );

  var x2 = x + x, y2 = y + y, z2 = z + z;
  var xx = x * x2, xy = x * y2, xz = x * z2;
  var yy = y * y2, yz = y * z2, zz = z * z2;
  var wx = w * x2, wy = w * y2, wz = w * z2;

  self.atomSet( [ 0,0 ] , 1 - ( yy + zz ) );
  self.atomSet( [ 0,1 ] , xy - wz );
  self.atomSet( [ 0,2 ] , xz + wy );

  self.atomSet( [ 1,0 ] , xy + wz );
  self.atomSet( [ 1,1 ] , 1 - ( xx + zz ) );
  self.atomSet( [ 1,2 ] , yz - wx );

  self.atomSet( [ 2,0 ] , xz - wy );
  self.atomSet( [ 2,1 ] , yz + wx );
  self.atomSet( [ 2,2 ] , 1 - ( xx + yy ) );

  if( self.dims[ 0 ] > 3 )
  {
    self.atomSet( [ 3,0 ] , 0 );
    self.atomSet( [ 3,1 ] , 0 );
    self.atomSet( [ 3,2 ] , 0 );
    self.atomSet( [ 0,3 ], 0 );
    self.atomSet( [ 1,3 ], 0 );
    self.atomSet( [ 2,3 ], 0 );
    self.atomSet( [ 3,3 ], 1 );
  }

  return self;
}

//

function fromQuatWithScale( q )
{
  var self = this;

  var q = _.vector.from( q );
  var m = q.mag();
  var x = q.eGet( 0 ) / m;
  var y = q.eGet( 1 ) / m;
  var z = q.eGet( 2 ) / m;
  var w = q.eGet( 3 ) / m;

  _.assert( self.atomsPerElement >= 3 );
  _.assert( self.length >= 3 );
  _.assert( q.length === 4 );
  _.assert( arguments.length === 1, 'expects single argument' );

  var x2 = x + x, y2 = y + y, z2 = z + z;
  var xx = x * x2, xy = x * y2, xz = x * z2;
  var yy = y * y2, yz = y * z2, zz = z * z2;
  var wx = w * x2, wy = w * y2, wz = w * z2;

  self.atomSet( [ 0,0 ] , m*( 1 - ( yy + zz ) ) );
  self.atomSet( [ 0,1 ] , m*( xy - wz ) );
  self.atomSet( [ 0,2 ] , m*( xz + wy ) );

  self.atomSet( [ 1,0 ] , m*( xy + wz ) );
  self.atomSet( [ 1,1 ] , m*( 1 - ( xx + zz ) ) );
  self.atomSet( [ 1,2 ] , m*( yz - wx ) );

  self.atomSet( [ 2,0 ] , m*( xz - wy ) );
  self.atomSet( [ 2,1 ] , m*( yz + wx ) );
  self.atomSet( [ 2,2 ] , m*( 1 - ( xx + yy ) ) );

  if( self.dims[ 0 ] > 3 )
  {
    self.atomSet( [ 3,0 ] , 0 );
    self.atomSet( [ 3,1 ] , 0 );
    self.atomSet( [ 3,2 ] , 0 );
    self.atomSet( [ 0,3 ], 0 );
    self.atomSet( [ 1,3 ], 0 );
    self.atomSet( [ 2,3 ], 0 );
    self.atomSet( [ 3,3 ], 1 );
  }

  return self;
}

//

function fromAxisAndAngle( axis,angle )
{
  var self = this;
  var axis = _.vector.from( axis );

  // var m = axis.mag();
  // debugger;

  var x = axis.eGet( 0 );
  var y = axis.eGet( 1 );
  var z = axis.eGet( 2 );

  _.assert( axis.length === 3 );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  var s = Math.sin( angle );
  var c = Math.cos( angle );
  var t = 1 - c;

  var m00 = c + x*x*t;
  var m11 = c + y*y*t;
  var m22 = c + z*z*t;

  var a = x*y*t;
  var b = z*s;

  var m10 = a + b;
  var m01 = a - b;

  var a = x*z*t;
  var b = y*s;

  var m20 = a - b;
  var m02 = a + b;

  var a = y*z*t;
  var b = x*s;

  var m21 = a + b;
  var m12 = a - b;

  self.atomSet( [ 0,0 ],m00 );
  self.atomSet( [ 1,0 ],m10 );
  self.atomSet( [ 2,0 ],m20 );

  self.atomSet( [ 0,1 ],m01 );
  self.atomSet( [ 1,1 ],m11 );
  self.atomSet( [ 2,1 ],m21 );

  self.atomSet( [ 0,2 ],m02 );
  self.atomSet( [ 1,2 ],m12 );
  self.atomSet( [ 2,2 ],m22 );

  return self;
}

//

function fromEuler( euler )
{
  var self = this;
  // var euler = _.vector.from( euler );

  // _.assert( self.dims[ 0 ] >= 3 );
  // _.assert( self.dims[ 1 ] >= 3 );
  _.assert( arguments.length === 1, 'expects single argument' );

  _.euler.toMatrix( euler,self );

  return self;
}

//

function fromAxisAndAngleWithScale( axis,angle )
{
  var self = this;
  var axis = _.vector.from( axis );

  var m = axis.mag();
  debugger;
  var x = axis.eGet( 0 ) / m;
  var y = axis.eGet( 1 ) / m;
  var z = axis.eGet( 2 ) / m;

  _.assert( axis.length === 3 );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  var s = Math.sin( angle );
  var c = Math.cos( angle );
  var t = 1 - c;

  var m00 = c + x*x*t;
  var m11 = c + y*y*t;
  var m22 = c + z*z*t;

  var a = x*y*t;
  var b = z*s;

  var m10 = a + b;
  var m01 = a - b;

  var a = x*z*t;
  var b = y*s;

  var m20 = a - b;
  var m02 = a + b;

  var a = y*z*t;
  var b = x*s;

  var m21 = a + b;
  var m12 = a - b;

  self.atomSet( [ 0,0 ],m*m00 );
  self.atomSet( [ 1,0 ],m*m10 );
  self.atomSet( [ 2,0 ],m*m20 );

  self.atomSet( [ 0,1 ],m*m01 );
  self.atomSet( [ 1,1 ],m*m11 );
  self.atomSet( [ 2,1 ],m*m21 );

  self.atomSet( [ 0,2 ],m*m02 );
  self.atomSet( [ 1,2 ],m*m12 );
  self.atomSet( [ 2,2 ],m*m22 );

  return self;
}

// --
// borrow
// --

function _tempBorrow( src,dims,index )
{
  var cls , dims;

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( src instanceof Self || src === null );
  _.assert( _.arrayIs( dims ) || dims instanceof Self || dims === null );

  if( !src )
  {

    cls = this.array.ArrayType;
    if( !dims )
    dims = src;

  }
  else
  {

    if( src.buffer )
    cls = src.buffer.constructor;

    if( !dims )
    if( src.dims )
    dims = src.dims.slice();

  }

  if( dims instanceof Self )
  dims = dims.dims;

  _.assert( _.routineIs( cls ) );
  _.assert( _.arrayIs( dims ) );
  _.assert( index < 3 );

  var key = cls.name + '_' + dims.join( 'x' );

  if( this._tempMatrices[ index ][ key ] )
  return this._tempMatrices[ index ][ key ];

  var result = this._tempMatrices[ index ][ key ] = new Self
  ({
    dims : dims,
    buffer : new cls( this.atomsPerSpaceForDimensions( dims ) ),
    inputTransposing : 0,
  });

  return result;
}

//

function tempBorrow1( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 0 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 0 );
  else
  return Self._tempBorrow( null, src , 0 );

}

//

function tempBorrow2( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 1 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 1 );
  else
  return Self._tempBorrow( null, src , 1 );

}

//

function tempBorrow3( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 2 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 2 );
  else
  return Self._tempBorrow( null, src , 2 );

}

// --
// mul
// --

function spacePow( exponent )
{

  _.assert( _.instanceIs( this ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  var t = this.tempBorrow( this );

  // self.mul(  );

}

//

function mul_static( dst,srcs )
{

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.arrayIs( srcs ) );
  _.assert( srcs.length >= 2 );

  /* adjust dst */

  if( dst === null )
  {
    var dims = [ this.nrowOf( srcs[ srcs.length-2 ] ) , this.ncolOf( srcs[ srcs.length-1 ] ) ];
    dst = this.makeSimilar( srcs[ srcs.length-1 ] , dims );
  }

  /* adjust srcs */

  var srcs = srcs.slice();
  var dstClone = null;

  var odst = dst;
  dst = this.from( dst );

  for( var s = 0 ; s < srcs.length ; s++ )
  {

    srcs[ s ] = this.from( srcs[ s ] );

    if( dst === srcs[ s ] || dst.buffer === srcs[ s ].buffer )
    {
      if( dstClone === null )
      {
        dstClone = dst.tempBorrow1();
        dstClone.copy( dst );
      }
      srcs[ s ] = dstClone;
    }

    _.assert( dst.buffer !== srcs[ s ].buffer );

  }

  /* */

  dst = this.mul2Matrices( dst , srcs[ 0 ] , srcs[ 1 ] );

  /* */

  if( srcs.length > 2 )
  {

    var dst2 = null;
    var dst3 = dst;
    for( var s = 2 ; s < srcs.length ; s++ )
    {
      var src = srcs[ s ];
      if( s % 2 === 0 )
      {
        var dst2 = dst.tempBorrow2([ dst3.dims[ 0 ],src.dims[ 1 ] ]);
        this.mul2Matrices( dst2 , dst3 , src );
      }
      else
      {
        var dst3 = dst.tempBorrow3([ dst2.dims[ 0 ],src.dims[ 1 ] ]);
        this.mul2Matrices( dst3 , dst2 , src );
      }
    }

    if( srcs.length % 2 === 0 )
    this.copyTo( odst,dst3 );
    else
    this.copyTo( odst,dst2 );

  }
  else
  {
    this.copyTo( odst,dst );
  }

  return odst;
}

//

function mul( srcs )
{
  var dst = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( srcs ) );

  return dst.Self.mul( dst,srcs );
}

//

function mul2Matrices_static( dst,src1,src2 )
{

  src1 = Self.fromForReading( src1 );
  src2 = Self.fromForReading( src2 );

  if( dst === null )
  {
    dst = this.make([ src1.dims[ 0 ],src2.dims[ 1 ] ]);
  }

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( src1.dims.length === 2 );
  _.assert( src2.dims.length === 2 );
  _.assert( dst instanceof Self );
  _.assert( src1 instanceof Self );
  _.assert( src2 instanceof Self );
  _.assert( dst !== src1 );
  _.assert( dst !== src2 );
  _.assert( src1.dims[ 1 ] === src2.dims[ 0 ],'expects src1.dims[ 1 ] === src2.dims[ 0 ]' );
  _.assert( src1.dims[ 0 ] === dst.dims[ 0 ] );
  _.assert( src2.dims[ 1 ] === dst.dims[ 1 ] );

  var nrow = dst.nrow;
  var ncol = dst.ncol;

  for( var r = 0 ; r < nrow ; r++ )
  for( var c = 0 ; c < ncol ; c++ )
  {
    var row = src1.rowVectorGet( r );
    var col = src2.colVectorGet( c );
    var dot = vector.dot( row,col );
    dst.atomSet( [ r,c ],dot );
  }

  return dst;
}

//

function mul2Matrices( src1,src2 )
{
  var dst = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  return dst.Self.mul2Matrices( dst,src1,src2 );
}

//

function mulLeft( src )
{
  var dst = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  // debugger;

  dst.mul([ dst,src ])

  return dst;
}

//

function mulRight( src )
{
  var dst = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  // debugger;

  dst.mul([ src,dst ]);
  // dst.mul2Matrices( src,dst );

  return dst;
}

// //
//
// function _mulMatrix( src )
// {
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( src.breadth.length === 1 );
//
//   var self = this;
//   var atomsPerRow = self.atomsPerRow;
//   var atomsPerCol = src.atomsPerCol;
//   var code = src.buffer.constructor.name + '_' + atomsPerRow + 'x' + atomsPerCol;
//
//   debugger;
//   if( !self._tempMatrices[ code ] )
//   self._tempMatrices[ code ] = self.Self.make([ atomsPerCol,atomsPerRow ]);
//   var dst = self._tempMatrices[ code ]
//
//   debugger;
//   dst.mul2Matrices( dst,self,src );
//   debugger;
//
//   self.copy( dst );
//
//   return self;
// }
//
// //
//
// function mulAssigning( src )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( self.breadth.length === 1 );
//
//   var result = self._mulMatrix( src );
//
//   return result;
// }
//
// //
//
// function mulCopying( src )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( src.dims.length === 2 );
//   _.assert( self.dims.length === 2 );
//
//   var result = Self.make( src.dims );
//   result.mul2Matrices( result,self,src );
//
//   return result;
// }

// --
// partial accessors
// --

function zero()
{
  var self = this;

  _.assert( arguments.length === 0 );

  self.atomEach( ( it ) => self.atomSet( it.indexNd,0 ) );

  return self;
}

//

function identify()
{
  var self = this;

  _.assert( arguments.length === 0 );

  self.atomEach( ( it ) => it.indexNd[ 0 ] === it.indexNd[ 1 ] ? self.atomSet( it.indexNd,1 ) : self.atomSet( it.indexNd,0 ) );

  return self;
}

//

function diagonalSet( src )
{
  var self = this;
  var length = Math.min( self.atomsPerCol,self.atomsPerRow );

  if( src instanceof Self )
  src = src.diagonalVectorGet();

  src = vector.fromMaybeNumber( src,length );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.dims.length === 2 );
  _.assert( src.length === length );

  for( var i = 0 ; i < length ; i += 1 )
  {
    self.atomSet( [ i,i ],src.eGet( i ) );
  }

  return self;
}

//

function diagonalVectorGet()
{
  var self = this;
  var length = Math.min( self.atomsPerCol,self.atomsPerRow );
  var strides = self._stridesEffective;

  _.assert( arguments.length === 0 );
  _.assert( self.dims.length === 2 );

  var result = vector.fromSubArrayWithStride( self.buffer, self.offset, length, strides[ 0 ] + strides[ 1 ] );

  return result;
}

//

function triangleLowerSet( src )
{
  var self = this;
  var nrow = self.nrow;
  var ncol = self.ncol;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 0 ] >= self.dims[ 0 ] );
    _.assert( src.dims[ 1 ] >= min( self.dims[ 0 ]-1,self.dims[ 1 ] ) );

    for( var r = 1 ; r < nrow ; r++ )
    {
      var cl = min( r,ncol );
      for( var c = 0 ; c < cl ; c++ )
      self.atomSet( [ r,c ],src.atomGet([ r,c ]) );
    }

  }
  else
  {

    for( var r = 1 ; r < nrow ; r++ )
    {
      var cl = min( r,ncol );
      for( var c = 0 ; c < cl ; c++ )
      self.atomSet( [ r,c ],src );
    }

  }

  return self;
}

//

function triangleUpperSet( src )
{
  var self = this;
  var nrow = self.nrow;
  var ncol = self.ncol;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 1 ] >= self.dims[ 1 ] );
    _.assert( src.dims[ 0 ] >= min( self.dims[ 1 ]-1,self.dims[ 0 ] ) );

    for( var c = 1 ; c < ncol ; c++ )
    {
      var cl = min( c,nrow );
      for( var r = 0 ; r < cl ; r++ )
      self.atomSet( [ r,c ],src.atomGet([ r,c ]) );
    }

  }
  else
  {

    for( var c = 1 ; c < ncol ; c++ )
    {
      var cl = min( c,nrow );
      for( var r = 0 ; r < cl ; r++ )
      self.atomSet( [ r,c ],src );
    }

  }

  return self;
}

// --
// transformer
// --

// function applyMatrixToVector( dstVector )
// {
//   var self = this;
//
//   _.assert( 0,'deprecated' );
//
//   vector.matrixApplyTo( dstVector,self );
//
//   return self;
// }

//

// function matrixHomogenousApply( dstVector )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 )
//   _.assert( 0,'not tested' );
//
//   vector.matrixHomogenousApply( dstVector,self );
//
//   return self;
// }

function matrixApplyTo( dstVector )
{
  var self = this;

  if( self.hasShape([ 3,3 ]) )
  {

    var dstVectorv = _.vector.from( dstVector );
    var x = dstVectorv.eGet( 0 );
    var y = dstVectorv.eGet( 1 );
    var z = dstVectorv.eGet( 2 );

    var s00 = self.atomGet([ 0,0 ]), s10 = self.atomGet([ 1,0 ]), s20 = self.atomGet([ 2,0 ]);
    var s01 = self.atomGet([ 0,1 ]), s11 = self.atomGet([ 1,1 ]), s21 = self.atomGet([ 2,1 ]);
    var s02 = self.atomGet([ 0,2 ]), s12 = self.atomGet([ 1,2 ]), s22 = self.atomGet([ 2,2 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y + s02 * z );
    dstVectorv.eSet( 1 , s10 * x + s11 * y + s12 * z );
    dstVectorv.eSet( 2 , s20 * x + s21 * y + s22 * z );

    return dstVector;
  }
  else if( self.hasShape([ 2,2 ]) )
  {

    var dstVectorv = _.vector.from( dstVector );
    var x = dstVectorv.eGet( 0 );
    var y = dstVectorv.eGet( 1 );

    var s00 = self.atomGet([ 0,0 ]), s10 = self.atomGet([ 1,0 ]);
    var s01 = self.atomGet([ 0,1 ]), s11 = self.atomGet([ 1,1 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y );
    dstVectorv.eSet( 1 , s10 * x + s11 * y );

    return dstVector;
  }

  return Self.mul( dstVector,[ self,dstVector ] );
}

//

function matrixHomogenousApply( dstVector )
{
  var self = this;
  var _dstVector = vector.from( dstVector );
  var dstLength = dstVector.length;
  var ncol = self.ncol;
  var nrow = self.nrow;
  var result = new Array( nrow );

  _.assert( arguments.length === 1 )
  _.assert( dstLength === ncol-1 );

  result[ dstLength ] = 0;
  for( var i = 0 ; i < nrow ; i += 1 )
  {
    var row = self.rowVectorGet( i );

    result[ i ] = 0;
    for( var j = 0 ; j < dstLength ; j++ )
    result[ i ] += row.eGet( j ) * _dstVector.eGet( j );
    result[ i ] += row.eGet( dstLength );

  }

  for( var j = 0 ; j < dstLength ; j++ )
  _dstVector.eSet( j,result[ j ] / result[ dstLength ] );

  return dstVector;
}

//

function matrixDirectionsApply( dstVector )
{
  var self = this;
  var dstLength = dstVector.length;
  var ncol = self.ncol;
  var nrow = self.nrow;

  _.assert( arguments.length === 1 )
  _.assert( dstLength === ncol-1 );

  debugger;

  Self.mul( v,[ self.subspace([ [ 0,v.length ],[ 0,v.length ] ]),v ] );
  vector.normalize( v );

  return dstVector;
}
//

function positionGet()
{
  var self = this;
  var l = self.length;
  var loe = self.atomsPerElement;
  var result = self.colVectorGet( l-1 );

  _.assert( arguments.length === 0 );

  // debugger;
  result = vector.fromSubArray( result,0,loe-1 );

  //var result = self.elementsInRangeGet([ (l-1)*loe,l*loe ]);
  //var result = vector.fromSubArray( this.buffer,12,3 );

  return result;
}

//

function positionSet( src )
{
  var self = this;
  var src = vector.fromArray( src );
  var dst = this.positionGet();

  _.assert( src.length === dst.length );

  vector.assign( dst, src );
  return dst;
}

//

function scaleMaxGet( dst )
{
  var self = this;
  var scale = self.scaleGet( dst );
  var result = _.avector.reduceToMaxAbs( scale ).value;
  return result;
}

//

function scaleMeanGet( dst )
{
  var self = this;
  var scale = self.scaleGet( dst );
  var result = _.avector.reduceToMean( scale );
  return result;
}

//

function scaleMagGet( dst )
{
  var self = this;
  var scale = self.scaleGet( dst );
  var result = _.avector.mag( scale );
  return result;
}

//

function scaleGet( dst )
{
  var self = this;
  var l = self.length-1;
  var loe = self.atomsPerElement;

  if( dst )
  {
    if( _.arrayIs( dst ) )
    dst.length = self.length-1;
  }

  if( dst )
  l = dst.length;
  else
  dst = _.vector.from( self.array.makeArrayOfLengthZeroed( self.length-1 ) );

  var dstv = _.vector.from( dst );

  _.assert( arguments.length === 0 || arguments.length === 1 );

  for( var i = 0 ; i < l ; i += 1 )
  dstv.eSet( i , vector.mag( vector.fromSubArray( this.buffer,loe*i,loe-1 ) ) );

  return dst;
}

//

function scaleSet( src )
{
  var self = this;
  var src = vector.fromArray( src );
  var l = self.length;
  var loe = self.atomsPerElement;
  var cur = this.scaleGet();

  _.assert( src.length === l-1 );

  for( var i = 0 ; i < l-1 ; i += 1 )
  vector.mulScalar( self.eGet( i ),src.eGet( i ) / cur[ i ] );

  var lastElement = self.eGet( l-1 );
  vector.mulScalar( lastElement,1 / lastElement.eGet( loe-1 ) );

}

//

function scaleAroundSet( scale,center )
{
  var self = this;
  var scale = vector.fromArray( scale );
  var l = self.length;
  var loe = self.atomsPerElement;
  var cur = this.scaleGet();

  _.assert( scale.length === l-1 );

  for( var i = 0 ; i < l-1 ; i += 1 )
  vector.mulScalar( self.eGet( i ),scale.eGet( i ) / cur[ i ] );

  var lastElement = self.eGet( l-1 );
  vector.mulScalar( lastElement,1 / lastElement.eGet( loe-1 ) );

  /* */

  debugger;
  var center = vector.fromArray( center );
  var pos = vector.slice( scale );
  pos = vector.fromArray( pos );
  vector.mulScalar( pos,-1 );
  vector.addScalar( pos, 1 );
  vector.mulVectors( pos, center );

  self.positionSet( pos );

}

//

function scaleApply( src )
{
  var self = this;
  var src = vector.fromArray( src );
  var ape = self.atomsPerElement;
  var l = self.length;

  for( var i = 0 ; i < ape ; i += 1 )
  {
    var c = self.rowVectorGet( i );
    c = vector.fromSubArray( c,0,l-1 );
    vector.mulVectors( c,src );
  }

}

// --
// triangulator
// --

function _triangulateGausian( o )
{
  var self = this;
  var nrow = self.nrow;
  var ncol = Math.min( self.ncol,nrow );

  _.routineOptions( _triangulateGausian,o );

  if( o.onPivot && !o.pivots )
  {
    o.pivots = [];
    for( var i = 0 ; i < self.dims.length ; i += 1 )
    o.pivots[ i ] = _.arrayFromRange([ 0, self.dims[ i ] ]);
  }

  if( o.y !== null )
  o.y = Self.from( o.y );

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !o.y || o.y.dims[ 0 ] === self.dims[ 0 ] );

  /* */

  if( o.y )
  for( var r1 = 0 ; r1 < ncol ; r1++ )
  {

    if( o.onPivot )
    o.onPivot.call( self,r1,o );

    var row1 = self.rowVectorGet( r1 );
    var yrow1 = o.y.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );
    if( o.normal )
    {
      vector.divScalar( row1,scaler1 );
      vector.divScalar( yrow1,scaler1 );
      scaler1 = 1;
    }

    for( var r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      var row2 = self.rowVectorGet( r2 );
      var yrow2 = o.y.rowVectorGet( r2 );
      var scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2,row1,scaler );
      vector.subScaled( yrow2,yrow1,scaler );
    }

    // logger.log( 'self',self );

  }
  else for( var r1 = 0 ; r1 < ncol ; r1++ )
  {

    if( o.onPivot )
    o.onPivot.call( self,r1,o );

    var row1 = self.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );
    if( o.normal )
    {
      vector.divScalar( row1,scaler1 );
      scaler1 = 1;
    }

    for( var r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      var row2 = self.rowVectorGet( r2 );
      var scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2,row1,scaler );
    }

    // logger.log( 'self',self );

  }

  return o.pivots;
}

_triangulateGausian.defaults =
{
  y : null,
  onPivot : null,
  pivots : null,
  normal : 0,
}

//

function triangulateGausian( y )
{
  var self = this;
  var o = Object.create( null );
  o.y = y;
  return self._triangulateGausian( o );

  // var self = this;
  // var nrow = self.nrow;
  // var ncol = Math.min( self.ncol,nrow );
  //
  // if( y !== undefined )
  // y = Self.from( y );
  //
  // _.assert( arguments.length === 0 || arguments.length === 1 );
  // _.assert( !y || y.dims[ 0 ] === self.dims[ 0 ] );
  //
  // if( y )
  // for( var r1 = 0 ; r1 < ncol ; r1++ )
  // {
  //   var row1 = self.rowVectorGet( r1 );
  //   var yrow1 = y.rowVectorGet( r1 );
  //   var scaler1 = row1.eGet( r1 );
  //
  //   for( var r2 = r1+1 ; r2 < nrow ; r2++ )
  //   {
  //     var row2 = self.rowVectorGet( r2 );
  //     var yrow2 = y.rowVectorGet( r2 );
  //     var scaler = row2.eGet( r1 ) / scaler1;
  //     vector.subScaled( row2,row1,scaler );
  //     vector.subScaled( yrow2,yrow1,scaler );
  //   }
  //
  // }
  // else for( var r1 = 0 ; r1 < ncol ; r1++ )
  // {
  //   var row1 = self.rowVectorGet( r1 );
  //
  //   for( var r2 = r1+1 ; r2 < nrow ; r2++ )
  //   {
  //     var row2 = self.rowVectorGet( r2 );
  //     var scaler = row2.eGet( r1 ) / row1.eGet( r1 );
  //     vector.subScaled( row2,row1,scaler );
  //   }
  //
  // }
  //
  // return self;
}

//

function triangulateGausianNormal( y )
{
  var self = this;
  var o = Object.create( null );
  o.y = y;
  o.normal = 1;
  return self._triangulateGausian( o );

  //

  var self = this;
  var nrow = self.nrow;
  var ncol = Math.min( self.ncol,nrow );

  if( y !== undefined )
  y = Self.from( y );

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !y || y.dims[ 0 ] === self.dims[ 0 ] );

  if( y )
  for( var r1 = 0 ; r1 < ncol ; r1++ )
  {
    var row1 = self.rowVectorGet( r1 );
    var yrow1 = y.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );
    vector.divScalar( row1,scaler1 );
    vector.divScalar( yrow1,scaler1 );

    for( var r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      var row2 = self.rowVectorGet( r2 );
      var yrow2 = y.rowVectorGet( r2 );
      var scaler = row2.eGet( r1 );
      vector.subScaled( row2,row1,scaler );
      vector.subScaled( yrow2,yrow1,scaler );
    }

  }
  else for( var r1 = 0 ; r1 < ncol ; r1++ )
  {
    var row1 = self.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );
    vector.divScalar( row1,scaler1 );

    for( var r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      var row2 = self.rowVectorGet( r2 );
      var scaler = row2.eGet( r1 );
      vector.subScaled( row2,row1,scaler );
    }

  }

  return self;
}

//

function triangulateGausianPivoting( y )
{
  var self = this;
  var o = Object.create( null );
  o.y = y;
  o.onPivot = self._pivotRook;
  return self._triangulateGausian( o );
}

//

function triangulateLu()
{
  var self = this;
  var nrow = self.nrow;
  var ncol = Math.min( self.ncol,nrow );

  _.assert( arguments.length === 0 );

  logger.log( 'self',self );

  for( var r1 = 0 ; r1 < ncol ; r1++ )
  {
    var row1 = self.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );
    row1 = row1.subarray( r1+1 );

    for( var r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      var row2 = self.rowVectorGet( r2 );
      var scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2.subarray( r1+1 ),row1,scaler );
      row2.eSet( r1, scaler );
    }

    logger.log( 'self',self );
  }

  return self;
}

//

function triangulateLuNormal()
{
  var self = this;
  var nrow = self.nrow;
  var ncol = Math.min( self.ncol,nrow );

  _.assert( arguments.length === 0 );

  for( var r1 = 0 ; r1 < ncol ; r1++ )
  {
    var row1 = self.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );
    row1 = row1.subarray( r1+1 );
    vector.divScalar( row1,scaler1 );

    for( var r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      var row2 = self.rowVectorGet( r2 );
      var scaler = row2.eGet( r1 );
      vector.subScaled( row2.subarray( r1+1 ),row1,scaler );
      row2.eSet( r1, scaler );
    }

  }

  return self;
}

//

function triangulateLuPivoting( pivots )
{
  var self = this;
  var nrow = self.nrow;
  var ncol = Math.min( self.ncol,nrow );

  if( !pivots )
  {
    pivots = [];
    for( var i = 0 ; i < self.dims.length ; i += 1 )
    pivots[ i ] = _.arrayFromRange([ 0, self.dims[ i ] ]);
  }

  var o = Object.create( null );
  o.pivots = pivots;

  /* */

  _.assert( self.dims.length === 2 );
  _.assert( _.arrayIs( pivots ) );
  _.assert( pivots.length === 2 );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  /* */

  logger.log( 'self',self );

  for( var r1 = 0 ; r1 < ncol ; r1++ )
  {

    self._pivotRook.call( self, r1, o );

    var row1 = self.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );
    row1 = row1.subarray( r1+1 );

    for( var r2 = r1+1 ; r2 < nrow ; r2++ )
    {
      var row2 = self.rowVectorGet( r2 );
      var scaler = row2.eGet( r1 ) / scaler1;
      vector.subScaled( row2.subarray( r1+1 ),row1,scaler );
      row2.eSet( r1, scaler );
    }

    logger.log( 'self',self );

  }

  return pivots;
}

//

function _pivotRook( i,o )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( o.pivots )

  var row1 = self.rowVectorGet( i ).subarray( i );
  var col1 = self.colVectorGet( i ).subarray( i );
  var value = row1.eGet( 0 );

  var maxr = vector.reduceToMaxAbs( row1 );
  var maxc = vector.reduceToMaxAbs( col1 );

  if( maxr.value > maxc.value )
  {
    if( maxr.value === value )
    return false;
    var i2 = maxr.index + i;
    _.arraySwap( o.pivots[ 1 ],i,i2 );
    self.colsSwap( i,i2 );
  }
  else
  {
    if( maxc.value === value )
    return false;
    var i2 = maxc.index + i;
    _.arraySwap( o.pivots[ 0 ],i,i2 );
    self.rowsSwap( i,i2 );
    if( o.y )
    o.y.rowsSwap( i,i2 );
  }

  return true;
}

// --
// solver
// --

function solve( x,m,y )
{
  _.assert( arguments.length === 3, 'expects exactly three argument' );
  return this.solveWithTrianglesPivoting( x,m,y )
}

//

function _solveOptions( args )
{
  var o = Object.create( null );
  o.x = args[ 0 ];
  o.m = args[ 1 ];
  o.y = args[ 2 ];

  o.oy = o.y;
  o.ox = o.x;

  if( o.x === null )
  {
    if( _.longIs( o.y ) )
    o.x = o.y.slice();
    else
    o.x = o.y.clone();
    o.ox = o.x;
  }
  else
  {
    if( !_.spaceIs( o.x ) )
    o.x = vector.from( o.x );
    this.copyTo( o.x,o.y );
  }

  if( !_.spaceIs( o.y ) )
  o.y = vector.from( o.y );

  if( !_.spaceIs( o.x ) )
  o.x = vector.from( o.x );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( this.shapesAreSame( o.x , o.y ) );
  _.assert( o.m.dims[ 0 ] === this.nrowOf( o.x ) );

  return o;
}

//

function solveWithGausian()
{
  var o = this._solveOptions( arguments );

  o.m.triangulateGausian( o.x );
  this.solveTriangleUpper( o.x,o.m,o.x );

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function solveWithGausianPivoting()
{
  var o = this._solveOptions( arguments );

  var pivots = o.m.triangulateGausianPivoting( o.x );
  this.solveTriangleUpper( o.x,o.m,o.x );
  Self.vectorPivotBackward( o.x,pivots[ 1 ] );

  return o.ox;
}

//

function _solveWithGaussJordan( o )
{

  var nrow = o.m.nrow;
  var ncol = Math.min( o.m.ncol,nrow );

  o.x = this.from( o.x );
  o.y = o.x;

  /* */

  if( o.onPivot && !o.pivots )
  {
    o.pivots = [];
    for( var i = 0 ; i < o.m.dims.length ; i += 1 )
    o.pivots[ i ] = _.arrayFromRange([ 0, o.m.dims[ i ] ]);
  }

  /* */

  for( var r1 = 0 ; r1 < ncol ; r1++ )
  {

    if( o.onPivot )
    o.onPivot.call( o.m,r1,o );

    var row1 = o.m.rowVectorGet( r1 );
    var scaler1 = row1.eGet( r1 );

    if( abs( scaler1 ) < this.accuracy )
    continue;

    vector.mulScalar( row1, 1/scaler1 );

    var xrow1 = o.x.rowVectorGet( r1 );
    vector.mulScalar( xrow1, 1/scaler1 );

    for( var r2 = 0 ; r2 < nrow ; r2++ )
    {

      if( r1 === r2 )
      continue;

      var xrow2 = o.x.rowVectorGet( r2 );
      var row2 = o.m.rowVectorGet( r2 );
      var scaler2 = row2.eGet( r1 );
      var scaler = scaler2;

      vector.subScaled( row2, row1, scaler );
      vector.subScaled( xrow2, xrow1, scaler );

    }

  }

  /* */

  if( o.onPivot && o.pivotingBackward )
  {
    Self.vectorPivotBackward( o.x,o.pivots[ 1 ] );
    /*o.m.pivotBackward( o.pivots );*/
  }

  /* */

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function solveWithGaussJordan()
{
  var o = this._solveOptions( arguments );
  return this._solveWithGaussJordan( o );
}

//

function solveWithGaussJordanPivoting()
{
  var o = this._solveOptions( arguments );
  o.onPivot = this._pivotRook;
  o.pivotingBackward = 1;
  return this._solveWithGaussJordan( o );
}

//

function invertWithGaussJordan()
{
  var m = this;

  _.assert( arguments.length === 0 );
  _.assert( m.dims[ 0 ] === m.dims[ 1 ] );

  var nrow = m.nrow;

  for( var r1 = 0 ; r1 < nrow ; r1++ )
  {

    var row1 = m.rowVectorGet( r1 ).subarray( r1+1 );
    var xrow1 = m.rowVectorGet( r1 ).subarray( 0,r1+1 );

    var scaler1 = 1 / xrow1.eGet( r1 );
    xrow1.eSet( r1, 1 );
    vector.mulScalar( row1, scaler1 );
    vector.mulScalar( xrow1, scaler1 );

    for( var r2 = 0 ; r2 < nrow ; r2++ )
    {

      if( r1 === r2 )
      continue;

      var row2 = m.rowVectorGet( r2 ).subarray( r1+1 );
      var xrow2 = m.rowVectorGet( r2 ).subarray( 0,r1+1 );
      var scaler2 = xrow2.eGet( r1 );
      xrow2.eSet( r1,0 )

      vector.subScaled( row2, row1, scaler2 );
      vector.subScaled( xrow2, xrow1, scaler2 );

    }

    // logger.log( 'm',m );

  }

  return m;
}

//

function solveWithTriangles( x,m,y )
{

  var o = this._solveOptions( arguments );
  m.triangulateLuNormal();

  o.x = this.solveTriangleLower( o.x,o.m,o.y );
  o.x = this.solveTriangleUpperNormal( o.x,o.m,o.x );

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function solveWithTrianglesPivoting( x,m,y )
{

  var o = this._solveOptions( arguments );
  var pivots = m.triangulateLuPivoting();

  o.y = Self.vectorPivotForward( o.y,pivots[ 0 ] );

  o.x = this.solveTriangleLowerNormal( o.x,o.m,o.y );
  o.x = this.solveTriangleUpper( o.x,o.m,o.x );

  Self.vectorPivotBackward( o.x,pivots[ 1 ] );
  Self.vectorPivotBackward( o.y,pivots[ 0 ] );

  // o.x = this.convertToClass( o.oy.constructor,o.x );
  return o.ox;
}

//

function _solveTriangleWithRoutine( args,onSolve )
{
  var x = args[ 0 ];
  var m = args[ 1 ];
  var y = args[ 2 ];

  _.assert( args.length === 3 );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( y );

  if( _.spaceIs( y ) )
  {

    if( x === null )
    {
      x = y.clone();
    }
    else
    {
      x = Self.from( x,y.dims );
      x.copy( y );
    }

    _.assert( x.hasShape( y ) );
    _.assert( x.dims[ 0 ] === m.dims[ 1 ] );

    for( var v = 0 ; v < y.dims[ 1 ] ; v++ )
    {
      onSolve( x.colVectorGet( v ),m,y.colVectorGet( v ) );
    }

    return x;
  }

  /* */

  var y = _.vector.from( y );

  if( x === null )
  {
    x = y.clone();
  }
  else
  {
    x = _.vector.from( x );
    x.copy( y );
  }

  /* */

  _.assert( x.length === y.length );

  return onSolve( x,m,y );
}

//

function solveTriangleLower( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( var r1 = 0 ; r1 < y.length ; r1++ )
    {
      var xu = x.subarray( 0,r1 );
      var row = m.rowVectorGet( r1 );
      var scaler = row.eGet( r1 );
      row = row.subarray( 0,r1 );
      var xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) ) / scaler;
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveTriangleLowerNormal( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( var r1 = 0 ; r1 < y.length ; r1++ )
    {
      var xu = x.subarray( 0,r1 );
      var row = m.rowVectorGet( r1 );
      row = row.subarray( 0,r1 );
      var xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) );
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveTriangleUpper( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( var r1 = y.length-1 ; r1 >= 0 ; r1-- )
    {
      var xu = x.subarray( r1+1,x.length );
      var row = m.rowVectorGet( r1 );
      var scaler = row.eGet( r1 );
      row = row.subarray( r1+1,row.length );
      var xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) ) / scaler;
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveTriangleUpperNormal( x,m,y )
{

  function handleSolve( x,m,y )
  {

    for( var r1 = y.length-1 ; r1 >= 0 ; r1-- )
    {
      var xu = x.subarray( r1+1,x.length );
      var row = m.rowVectorGet( r1 );
      row = row.subarray( r1+1,row.length );
      var xval = ( x.eGet( r1 ) - _.vector.dot( row,xu ) );
      x.eSet( r1,xval );
    }

    return x;
  }

  return this._solveTriangleWithRoutine( arguments,handleSolve );
}

//

function solveGeneral( o )
{

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( solveGeneral,o );

  /* */

  var result = Object.create( null );
  result.nsolutions = 1;
  result.kernel = o.kernel;
  result.nkernel = 0;

  /* alloc */

  if( o.m.nrow < o.m.ncol )
  {
    var missing = o.m.ncol - o.m.nrow;
    o.m.expand([ [ 0,missing ],0 ]);
    o.y.expand([ [ 0,missing ],0 ]);
  }

  if( !result.kernel )
  result.kernel = Self.makeZero( o.m.dims );
  var nrow = o.m.nrow;

  /* verify */

  _.assert( o.m.nrow === o.y.nrow );
  _.assert( o.m.nrow === result.kernel.nrow );
  _.assert( result.kernel.hasShape( o.m ) );
  _.assert( o.y instanceof Self );
  _.assert( o.y.dims[ 1 ] === 1 );

  /* solve */

  if( o.pivoting )
  {
    var optionsForMethod = this._solveOptions([ o.x,o.m,o.y ]);
    optionsForMethod.onPivot = this._pivotRook;
    optionsForMethod.pivotingBackward = 0;
    o.x = result.base = this._solveWithGaussJordan( optionsForMethod );
  }
  else
  {
    var optionsForMethod = this._solveOptions([ o.x,o.m,o.y ]);
    o.x = result.base = this._solveWithGaussJordan( optionsForMethod );
  }

  /* analyse */

  logger.log( 'm',o.m );
  logger.log( 'x',o.x );

  for( var r = 0 ; r < nrow ; r++ )
  {
    var row = o.m.rowVectorGet( r );
    if( abs( row.eGet( r ) ) < this.accuracy )
    {
      if( abs( o.x.atomGet([ r,0 ]) ) < this.accuracy )
      {
        result.nsolutions = Infinity;
        var termCol = result.kernel.colVectorGet( r );
        var srcCol = o.m.colVectorGet( r );
        termCol.copy( srcCol );
        vector.mulScalar( termCol,-1 );
        termCol.eSet( r,1 );
        result.nkernel += 1;
      }
      else
      {
        debugger;
        result.nsolutions = 0;
        return result;
      }
    }
  }

  if( o.pivoting )
  {
    debugger;
    Self.vectorPivotBackward( result.base,optionsForMethod.pivots[ 1 ] );
    result.kernel.pivotBackward([ optionsForMethod.pivots[ 1 ], optionsForMethod.pivots[ 0 ] ]);
    o.m.pivotBackward( optionsForMethod.pivots );
  }

  return result;
}

solveGeneral.defaults =
{
  x : null,
  m : null,
  y : null,
  kernel : null,
  pivoting : 1,
}

//

function invert()
{
  var self = this;

  _.assert( self.dims.length === 2 );
  _.assert( self.isSquare() );
  _.assert( arguments.length === 0 );

  return self.invertWithGaussJordan();
}

//

function invertingClone()
{
  var self = this;

  _.assert( self.dims.length === 2 );
  _.assert( self.isSquare() );
  _.assert( arguments.length === 0 );

  return Self.solveWithGaussJordan( null,self.clone(),self.Self.makeIdentity( self.dims[ 0 ] ) );
}

//

function copyAndInvert( src )
{
  var self = this;

  _.assert( self.dims.length === 2 );
  _.assert( self.isSquare() );
  _.assert( arguments.length === 1, 'expects single argument' );

  self.copy( src );
  self.invert();

  return self;
}

//

function normalProjectionMatrixMake()
{
  var self = this;
  debugger;
  return self.clone().invert().transpose();
}

//

function normalProjectionMatrixGet( src )
{
  var self = this;

  if( src.hasShape([ 4,4 ]) )
  {
    // debugger;

    var s00 = self.atomGet([ 0,0 ]), s10 = self.atomGet([ 1,0 ]), s20 = self.atomGet([ 2,0 ]);
    var s01 = self.atomGet([ 0,1 ]), s11 = self.atomGet([ 1,1 ]), s21 = self.atomGet([ 2,1 ]);
    var s02 = self.atomGet([ 0,2 ]), s12 = self.atomGet([ 1,2 ]), s22 = self.atomGet([ 2,2 ]);

    var d1 = s22 * s11 - s21 * s12;
    var d2 = s21 * s02 - s22 * s01;
    var d3 = s12 * s01 - s11 * s02;

    var determiant = s00 * d1 + s10 * d2 + s20 * d3;

    if( determiant === 0 )
    throw _.err( 'normalProjectionMatrixGet : zero determinant' );

    determiant = 1 / determiant;

    var d00 = d1 * determiant;
    var d10 = ( s20 * s12 - s22 * s10 ) * determiant;
    var d20 = ( s21 * s10 - s20 * s11 ) * determiant;

    var d01 = d2 * determiant;
    var d11 = ( s22 * s00 - s20 * s02 ) * determiant;
    var d21 = ( s20 * s01 - s21 * s00 ) * determiant;

    var d02 = d3 * determiant;
    var d12 = ( s10 * s02 - s12 * s00 ) * determiant;
    var d22 = ( s11 * s00 - s10 * s01 ) * determiant;

    self.atomSet( [ 0,0 ],d00 );
    self.atomSet( [ 1,0 ],d10 );
    self.atomSet( [ 2,0 ],d20 );

    self.atomSet( [ 0,1 ],d01 );
    self.atomSet( [ 1,1 ],d11 );
    self.atomSet( [ 2,1 ],d21 );

    self.atomSet( [ 0,2 ],d02 );
    self.atomSet( [ 1,2 ],d12 );
    self.atomSet( [ 2,2 ],d22 );

    return self;
  }

  // debugger;
  var sub = src.subspace([ [ 0,src.dims[ 0 ]-1 ],[ 0,src.dims[ 1 ]-1 ] ]);
  // debugger;

  return self.copy( sub ).invert().transpose();
}

// --
// top
// --

function _linearModel( o )
{

  _.routineOptions( polynomExactFor,o );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( o.order >= 1 );

  if( o.points )
  if( o.order === null )
  o.order = o.points.length;

  if( o.npoints === null )
  o.npoints = o.points ? o.points.length : o.order;

  var m = this.makeZero([ o.npoints,o.order ]);
  var ys = [];

  /* */

  var i = 0;
  function fixPoint( p )
  {
    ys[ i ] = p[ 1 ];
    var row = m.rowVectorGet( i )
    for( var d = 0 ; d < o.order ; d++ )
    row.eSet( d,pow( p[ 0 ],d ) );
    i += 1;
  }

  /* */

  if( o.points )
  {

    for( var p = 0 ; p < o.points.length ; p++ )
    fixPoint( o.points[ p ] );

  }
  else
  {

    if( o.domain === null )
    o.domain = [ 0,o.order ]

    _.assert( o.order === o.domain[ 1 ] - o.domain[ 0 ] )

    var x = o.domain[ 0 ];
    while( x < o.domain[ 1 ] )
    {
      var y = o.onFunction( x );
      fixPoint([ x,y ]);
      x += 1;
    }

  }

  /* */

  var result = Object.create( null );

  result.m = m;
  result.y = ys;

  return result;
}

_linearModel.defaults =
{
  npoints : null,
  points : null,
  domain : null,
  order : null,
  onFunction : null,
}

//

function polynomExactFor( o )
{

  _.routineOptions( polynomExactFor,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( o.points )
  _.assert( o.order === null || o.order === o.points.length );

  var model = this._linearModel( o );
  var result = this.solve( null , model.m , model.y );

  return result;
}

polynomExactFor.defaults =
{
}

polynomExactFor.defaults.__proto__ = _linearModel.defaults;

//

function polynomClosestFor( o )
{

  _.routineOptions( polynomExactFor,o );
  _.assert( arguments.length === 1, 'expects single argument' );

  var model = this._linearModel( o );

  var mt = model.m.clone().transpose();
  var y = this.mul( null , [ mt , model.y ] );
  var m = this.mul( null , [ mt , model.m ] );

  var result = this.solve( null , m , y );

  return result;
}

polynomClosestFor.defaults =
{
  points : null,
  domain : null,
  order : null,
  onFunction : null,
}

polynomClosestFor.defaults.__proto__ = _linearModel.defaults;

// --
// projector
// --

// function formPerspective( fov, width, height, near, far )
function formPerspective( fov, size, depth )
{
  var self = this;
  var aspect = size[ 0 ] / size[ 1 ];

  // debugger;
  // _.assert( 0,'not tested' );

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( size.length === 2 );
  _.assert( depth.length === 2 );
  _.assert( self.hasShape([ 4,4 ]) );

  var fov = Math.tan( THREE.Math.degToRad( fov * 0.5 ) );

  var ymin = - depth[ 0 ] * fov;
  var ymax = - ymin;

  var xmin = ymin;
  var xmax = ymax;

  var aspect = size[ 0 ] / size[ 1 ];

  if( aspect > 1 )
  {

    xmin *= aspect;
    xmax *= aspect;

  }
  else
  {

    ymin /= aspect;
    ymax /= aspect;

  }

  /* logger.log({ xmin : xmin, xmax : xmax, ymin : ymin, ymax : ymax }); */

  return self.formFrustum( [ xmin, xmax ], [ ymin, ymax ], depth );
}

//

// function formFrustum( left, right, bottom, top, near, far )
function formFrustum( horizontal, vertical, depth )
{
  var self = this;

  // debugger;
  // _.assert( 0,'not tested' );

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( horizontal.length === 2 );
  _.assert( vertical.length === 2 );
  _.assert( depth.length === 2 );
  _.assert( self.hasShape([ 4,4 ]) );

  // var te = this.buffer;
  var x = 2 * depth[ 0 ] / ( horizontal[ 1 ] - horizontal[ 0 ] );
  var y = 2 * depth[ 0 ] / ( vertical[ 1 ] - vertical[ 0 ] );

  var a = ( horizontal[ 1 ] + horizontal[ 0 ] ) / ( horizontal[ 1 ] - horizontal[ 0 ] );
  var b = ( vertical[ 1 ] + vertical[ 0 ] ) / ( vertical[ 1 ] - vertical[ 0 ] );
  var c = - ( depth[ 1 ] + depth[ 0 ] ) / ( depth[ 1 ] - depth[ 0 ] );
  var d = - 2 * depth[ 1 ] * depth[ 0 ] / ( depth[ 1 ] - depth[ 0 ] );

  self.atomSet( [ 0,0 ],x );
  self.atomSet( [ 1,0 ],0 );
  self.atomSet( [ 2,0 ],0 );
  self.atomSet( [ 3,0 ],0 );

  self.atomSet( [ 0,1 ],0 );
  self.atomSet( [ 1,1 ],y );
  self.atomSet( [ 2,1 ],0 );
  self.atomSet( [ 3,1 ],0 );

  self.atomSet( [ 0,2 ],a );
  self.atomSet( [ 1,2 ],b );
  self.atomSet( [ 2,2 ],c );
  self.atomSet( [ 3,2 ],-1 );

  self.atomSet( [ 0,3 ],0 );
  self.atomSet( [ 1,3 ],0 );
  self.atomSet( [ 2,3 ],d );
  self.atomSet( [ 3,3 ],0 );

  // debugger;
  return self;
}

//

// function formOrthographic( left, right, top, bottom, near, far )
function formOrthographic( horizontal, vertical, depth )
{
  var self = this;

  // debugger;
  // _.assert( 0,'not tested' );

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( horizontal.length === 2 );
  _.assert( vertical.length === 2 );
  _.assert( depth.length === 2 );
  _.assert( self.hasShape([ 4,4 ]) );

  var w = horizontal[ 1 ] - horizontal[ 0 ];
  var h = vertical[ 1 ] - vertical[ 0 ];
  var d = depth[ 1 ] - depth[ 0 ];

  var x = ( horizontal[ 1 ] + horizontal[ 0 ] ) / w;
  var y = ( vertical[ 1 ] + vertical[ 0 ] ) / h;
  var z = ( depth[ 1 ] + depth[ 0 ] ) / d;

  self.atomSet( [ 0,0 ],2 / w );
  self.atomSet( [ 1,0 ],0 );
  self.atomSet( [ 2,0 ],0 );
  self.atomSet( [ 3,0 ],0 );

  self.atomSet( [ 0,1 ],0 );
  self.atomSet( [ 1,1 ],2 / h );
  self.atomSet( [ 2,1 ],0 );
  self.atomSet( [ 3,1 ],0 );

  self.atomSet( [ 0,2 ],0 );
  self.atomSet( [ 1,2 ],0 );
  self.atomSet( [ 2,2 ],-2 / d );
  self.atomSet( [ 3,2 ],0 );

  self.atomSet( [ 0,3 ],-x );
  self.atomSet( [ 1,3 ],-y );
  self.atomSet( [ 2,3 ],-z );
  self.atomSet( [ 3,3 ],1 );

  // te[ 0 ] = 2 / w; te[ 4 ] = 0; te[ 8 ] = 0; te[ 12 ] = - x;
  // te[ 1 ] = 0; te[ 5 ] = 2 / h; te[ 9 ] = 0; te[ 13 ] = - y;
  // te[ 2 ] = 0; te[ 6 ] = 0; te[ 10 ] = - 2 / d; te[ 14 ] = - z;
  // te[ 3 ] = 0; te[ 7 ] = 0; te[ 11 ] = 0; te[ 15 ] = 1;

  return self;
}

//

var lookAt = ( function lookAt()
{

  var x = [ 0,0,0 ];
  var y = [ 0,0,0 ];
  var z = [ 0,0,0 ];

  return function( eye, target, up1 )
  {

    debugger;
    _.assert( 0,'not tested' );

    var self = this;
    var te = this.buffer;

    _.avector.subVectors( z, eye, target ).normalize();

    if ( _.avector.mag( z ) === 0 )
    {

      z[ 2 ] = 1;

    }

    debugger;
    _.avector._cross3( x, up1, z );
    var xmag = _.avector.mag( x );

    if ( xmag === 0 )
    {

      z[ 0 ] += 0.0001;
      _.avector._cross3( x,up1, z );
      xmag = _.avector.mag( x );

    }

    _.avector.mulScalar( x,1 / xmag );

    _.avector._cross3( y, z, x );

    te[ 0 ] = x[ 0 ]; te[ 4 ] = y[ 0 ]; te[ 8 ] = z[ 0 ];
    te[ 1 ] = x[ 1 ]; te[ 5 ] = y[ 1 ]; te[ 9 ] = z[ 1 ];
    te[ 2 ] = x[ 2 ]; te[ 6 ] = y[ 2 ]; te[ 10 ] = z[ 2 ];

    return this;
  }

})();

// --
// reducer
// --

function closest( insElement )
{
  var self = this;
  var insElement = vector.fromArray( insElement );
  var result =
  {
    index : null,
    distance : +Infinity,
  }

  _.assert( arguments.length === 1, 'expects single argument' );

  for( var i = 0 ; i < self.length ; i += 1 )
  {

    var d = vector.distanceSqr( insElement,self.eGet( i ) );
    if( d < result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function furthest( insElement )
{
  var self = this;
  var insElement = vector.fromArray( insElement );
  var result =
  {
    index : null,
    distance : -Infinity,
  }

  _.assert( arguments.length === 1, 'expects single argument' );

  for( var i = 0 ; i < self.length ; i += 1 )
  {

    var d = vector.distanceSqr( insElement,self.eGet( i ) );
    if( d > result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function elementMean()
{
  var self = this;

  var result = self.elementAdd();

  vector.divScalar( result,self.length );

  return result;
}

//

function minmaxColWise()
{
  var self = this;

  var minmax = self.distributionRangeSummaryValueColWise();
  var result = Object.create( null );

  result.min = self.array.makeSimilar( self.buffer,minmax.length );
  result.max = self.array.makeSimilar( self.buffer,minmax.length );


  for( var i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//

function minmaxRowWise()
{
  var self = this;

  var minmax = self.distributionRangeSummaryValueRowWise();
  var result = Object.create( null );

  result.min = self.array.makeSimilar( self.buffer,minmax.length );
  result.max = self.array.makeSimilar( self.buffer,minmax.length );

  for( var i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//

function determinant()
{
  var self = this;
  var l = self.length;

  if( l === 0 )
  return 0;

  var iterations = _.factorial( l );
  var result = 0;

  _.assert( l === self.atomsPerElement );

  /* */

  var sign = 1;
  var index = [];
  for( var i = 0 ; i < l ; i += 1 )
  index[ i ] = i;

  /* */

  function add()
  {
    var r = 1;
    for( var i = 0 ; i < l ; i += 1 )
    r *= self.atomGet([ index[ i ],i ]);
    r *= sign;
    // console.log( index );
    // console.log( r );
    result += r;
    return r;
  }

  /* */

  function swap( a,b )
  {
    var v = index[ a ];
    index[ a ] = index[ b ];
    index[ b ] = v;
    sign *= -1;
  }

  /* */

  var i = 0;
  while( i < iterations )
  {

    for( var s = 0 ; s < l-1 ; s++ )
    {
      var r = add();
      //console.log( 'add',i,index,r );
      swap( s,l-1 );
      i += 1;
    }

  }

  /* */

  // 00
  // 01
  //
  // 012
  // 021
  // 102
  // 120
  // 201
  // 210

  // console.log( 'determinant',result );

  return result;
}

// --
// relations
// --

var Statics =
{

  /* make */

  make : make,
  makeSquare : makeSquare,
  // makeSquare2 : makeSquare2,
  // makeSquare3 : makeSquare3,
  // makeSquare4 : makeSquare4,

  makeZero : makeZero,
  makeIdentity : makeIdentity,
  makeIdentity2 : makeIdentity2,
  makeIdentity3 : makeIdentity3,
  makeIdentity4 : makeIdentity4,

  makeDiagonal : makeDiagonal,
  makeSimilar : makeSimilar,

  makeLine : makeLine,
  makeCol : makeCol,
  makeColZeroed : makeColZeroed,
  makeRow : makeRow,
  makeRowZeroed : makeRowZeroed,

  fromVector : fromVector,
  fromScalar : fromScalar,
  fromScalarForReading : fromScalarForReading,
  from : from,
  fromForReading : fromForReading,

  _tempBorrow : _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1 : tempBorrow1,
  tempBorrow2 : tempBorrow2,
  tempBorrow3 : tempBorrow3,

  convertToClass : convertToClass,


  /* mul */

  mul : mul_static,
  mul2Matrices : mul2Matrices_static,


  /* solve */

  _pivotRook : _pivotRook,

  solve : solve,

  _solveOptions : _solveOptions,

  solveWithGausian : solveWithGausian,
  solveWithGausianPivoting : solveWithGausianPivoting,

  _solveWithGaussJordan : _solveWithGaussJordan,
  solveWithGaussJordan : solveWithGaussJordan,
  solveWithGaussJordanPivoting : solveWithGaussJordanPivoting,
  invertWithGaussJordan : invertWithGaussJordan,

  solveWithTriangles : solveWithTriangles,
  solveWithTrianglesPivoting : solveWithTrianglesPivoting,

  _solveTriangleWithRoutine : _solveTriangleWithRoutine,
  solveTriangleLower : solveTriangleLower,
  solveTriangleLowerNormal : solveTriangleLowerNormal,
  solveTriangleUpper : solveTriangleUpper,
  solveTriangleUpperNormal : solveTriangleUpperNormal,

  solveGeneral : solveGeneral,


  /* modeler */

  _linearModel : _linearModel,
  polynomExactFor : polynomExactFor,
  polynomClosestFor : polynomClosestFor,


  /* var */

  _tempMatrices : [ Object.create( null ) , Object.create( null ) , Object.create( null ) ],

}

/*
map
filter
reduce
zip
*/

// --
// define class
// --

var Extend =
{

  // make

  make : make,
  makeSquare : makeSquare,

  // makeSquare2 : makeSquare2,
  // makeSquare3 : makeSquare3,
  // makeSquare4 : makeSquare4,

  makeZero : makeZero,

  makeIdentity : makeIdentity,
  makeIdentity2 : makeIdentity2,
  makeIdentity3 : makeIdentity3,
  makeIdentity4 : makeIdentity4,

  makeDiagonal : makeDiagonal,
  makeSimilar : makeSimilar,

  makeLine : makeLine,
  makeCol : makeCol,
  makeColZeroed : makeColZeroed,
  makeRow : makeRow,
  makeRowZeroed : makeRowZeroed,

  // convert

  convertToClass : convertToClass,

  fromVector : fromVector,
  fromScalar : fromScalar,
  fromScalarForReading : fromScalarForReading,
  from : from,
  fromForReading : fromForReading,

  fromTransformations : fromTransformations,
  fromQuat : fromQuat,
  fromQuatWithScale : fromQuatWithScale,

  fromAxisAndAngle : fromAxisAndAngle,

  fromEuler : fromEuler,

  // borrow

  _tempBorrow : _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1 : tempBorrow1,
  tempBorrow2 : tempBorrow2,
  tempBorrow3 : tempBorrow3,

  // mul

  pow : spacePow,
  mul : mul,
  mul2Matrices : mul2Matrices,
  mulLeft : mulLeft,
  mulRight : mulRight,

  // partial accessors

  zero : zero,
  identify : identify,
  diagonalSet : diagonalSet,
  diagonalVectorGet : diagonalVectorGet,
  triangleLowerSet : triangleLowerSet,
  triangleUpperSet : triangleUpperSet,

  // transformer

  matrixApplyTo : matrixApplyTo,
  matrixHomogenousApply : matrixHomogenousApply,
  matrixDirectionsApply : matrixDirectionsApply,

  positionGet : positionGet,
  positionSet : positionSet,
  scaleMaxGet : scaleMaxGet,
  scaleMeanGet : scaleMeanGet,
  scaleMagGet : scaleMagGet,
  scaleGet : scaleGet,
  scaleSet : scaleSet,
  scaleAroundSet : scaleAroundSet,
  scaleApply : scaleApply,

  // triangulator

  _triangulateGausian : _triangulateGausian,
  triangulateGausian : triangulateGausian,
  triangulateGausianNormal : triangulateGausianNormal,
  triangulateGausianPivoting : triangulateGausianPivoting,

  triangulateLu : triangulateLu,
  triangulateLuNormal : triangulateLuNormal,
  triangulateLuPivoting : triangulateLuPivoting,

  _pivotRook : _pivotRook,

  // solver

  solve : solve,

  _solveOptions : _solveOptions,

  solveWithGausian : solveWithGausian,
  solveWithGausianPivoting : solveWithGausianPivoting,

  _solveWithGaussJordan : _solveWithGaussJordan,
  solveWithGaussJordan : solveWithGaussJordan,
  solveWithGaussJordanPivoting : solveWithGaussJordanPivoting,
  invertWithGaussJordan : invertWithGaussJordan,

  solveWithTriangles : solveWithTriangles,
  solveWithTrianglesPivoting : solveWithTrianglesPivoting,

  _solveTriangleWithRoutine : _solveTriangleWithRoutine,
  solveTriangleLower : solveTriangleLower,
  solveTriangleLowerNormal : solveTriangleLowerNormal,
  solveTriangleUpper : solveTriangleUpper,
  solveTriangleUpperNormal : solveTriangleUpperNormal,

  solveGeneral : solveGeneral,

  invert : invert,
  invertingClone : invertingClone,
  copyAndInvert : copyAndInvert,

  normalProjectionMatrixMake : normalProjectionMatrixMake,
  normalProjectionMatrixGet : normalProjectionMatrixGet,

  // modeler

  _linearModel : _linearModel,

  polynomExactFor : polynomExactFor,
  polynomClosestFor : polynomClosestFor,

  // projector

  formPerspective : formPerspective,
  formFrustum : formFrustum,
  formOrthographic : formOrthographic,
  lookAt : lookAt,

  // reducer

  closest : closest,
  furthest : furthest,

  elementMean : elementMean,

  minmaxColWise : minmaxColWise,
  minmaxRowWise : minmaxRowWise,

  determinant : determinant,

  //

  Statics : Statics,

}

_.classExtend( Self, Extend );
_.assert( Self.from === from );
_.assert( Self.mul2Matrices === mul2Matrices_static );
_.assert( Self.prototype.mul2Matrices === mul2Matrices );

})();
