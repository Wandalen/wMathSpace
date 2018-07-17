(function _wSpace_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }


  var _ = _global_.wTools;

  _.include( 'wMathScalar' );
  _.include( 'wMathVector' );
  _.include( 'wCopyable' );

  // require( '../arithmetic/cScalar.s' );
  // require( '../cvector/Base.s' );

}

/*

- implement power
- implement subspace
-- make sure inputTransposing of product set correctly
- implement compose

*/

//

var _ = _global_.wTools;
var abs = Math.abs;
var min = Math.min;
var max = Math.max;
var arraySlice = Array.prototype.slice;
var sqrt = Math.sqrt;
var sqr = _.sqr;
var vector = _.vector;
var accuracy = _.accuracy;
var accuracySqr = _.accuracySqr;

_.assert( vector,'wSpace : vector module needed' );

var Parent = null;
var Self = function wSpace( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

// --
// routine
// --

function init( o )
{
  var self = this;

  self._changing = [ 1 ];

  self[ stridesEffectiveSymbol ] = null;
  self[ lengthSymbol ] = null;
  self[ atomsPerElementSymbol ] = null;
  self[ occupiedRangeSymbol ] = null;
  self[ breadthSymbol ] = null;

  self[ stridesSymbol ] = null;
  self[ offsetSymbol ] = null;

  _.instanceInit( self );
  _.assert( arguments.length <= 1 );

  Object.preventExtensions( self );

  self.strides = null;
  self.offset = 0;
  self.breadth = null;

  self._changing[ 0 ] -= 1;

  if( o )
  {

    if( _.mapIs( o ) )
    {

      if( o.atomsPerElement !== undefined )
      {
        _.assert( _.arrayLike( o.buffer ) );
        // _.assert( !o.dims );
        if( !o.offset )
        o.offset = 0;
        if( !o.dims )
        {
          if( o.strides )
          o.dims = [ o.atomsPerElement, ( o.buffer.length - o.offset ) / o.strides[ 1 ] ];
          else
          o.dims = [ o.atomsPerElement, ( o.buffer.length - o.offset ) / o.atomsPerElement ];
          o.dims[ 1 ] = Math.floor( o.dims[ 1 ] );
        }
        _.assert( _.numberIsInt( o.dims[ 1 ] ) );
        delete o.atomsPerElement;
      }

      // if( o.dims === undefined && o.strides === undefined )
      // if( _.arrayLike( o.buffer ) )
      // {
      //   if( !o.offset )
      //   o.offset = 0;
      //   o.dims = [ o.buffer.length-o.offset,1 ];
      //   // o.dims = [ 1,o.buffer.length-o.offset ];
      // }

    }

    self.copy( o );
  }
  else
  {
    self._sizeChanged();
  }

}

//

function _traverseAct( it )
{

  if( it.resetting === undefined )
  it.resetting = 1;

  _.Copyable.prototype._traverseActPre.call( this,it );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( it.resetting !== undefined );
  _.assert( it.dst );
  // _.assert( it.dst._changeBegin );

  var dst = it.dst;
  var src = it.src;
  var srcIsInstance = src instanceof Self;
  var dstIsInstance = dst instanceof Self;

  if( src === dst )
  return dst;

  // if( src.buffer && src.buffer.length === 0 && src.offset === 0 && src.inputTransposing === 0 )
  // debugger;

  /* */

  if( _.arrayLike( src ) )
  {
    dst.copyFromBuffer( src );
    return dst;
  }
  else if( _.numberIs( src ) )
  {
    dst.copyFromScalar( src );
    return dst;
  }

  if( dstIsInstance )
  dst._changeBegin();

  if( src.dims )
  {
    _.assert( it.resetting || !dst.dims || _.arrayIdentical( dst.dims , src.dims ) );
  }

  if( dstIsInstance )
  if( dst._stridesEffective )
  dst[ stridesEffectiveSymbol ] = null;

  // if( src.buffer && src.buffer.length === 0 && src.offset === 0 && src.dims[ 0 ] === 1 && src.dims[ 1 ] === 0 )
  // debugger;

  // if( src.buffer && src.buffer.length === 0 && src.offset === 0 && src.inputTransposing === 0 )
  // debugger;

  /* */

  if( dstIsInstance )
  if( src.buffer !== undefined )
  {
    /* use here resetting option maybe!!!? */

    dst.dims = null;

    if( srcIsInstance && dst.buffer && dst.atomsPerSpace === src.atomsPerSpace )
    {
    }
    else if( !srcIsInstance )
    {
      dst.buffer = src.buffer;
      if( src.breadth !== undefined )
      dst.breadth = src.breadth;
      if( src.offset !== undefined )
      dst.offset = src.offset;
      if( src.strides !== undefined )
      dst.strides = src.strides;
    }
    else if( src.buffer && !dst.buffer )
    {
      dst.buffer = _.arrayMakeSimilar( src.buffer , src.atomsPerSpace );
      dst.offset = 0;
      dst.strides = null;
      dst[ stridesEffectiveSymbol ] = dst.stridesForDimensions( src.dims,!!dst.inputTransposing );
    }
    else if( src.buffer && dst.atomsPerSpace !== src.atomsPerSpace )
    {
      dst.buffer = _.arrayMakeSimilar( src.buffer , src.atomsPerSpace );
      dst.offset = 0;
      dst.strides = null;
      dst[ stridesEffectiveSymbol ] = dst.stridesForDimensions( src.dims,!!dst.inputTransposing );
    }
    else debugger;

  }

  /* */

  if( src.dims )
  dst.dims = src.dims;

  it.copyingAggregates = 0;
  dst = _.Copyable.prototype._traverseAct( it );

  if( srcIsInstance )
  _.assert( _.arrayIdentical( dst.dims , src.dims ) );

  if( dstIsInstance )
  {
    dst._changeEnd();
    _.assert( dst._changing[ 0 ] === 0 );
  }

  if( srcIsInstance )
  {

    if( dstIsInstance )
    {
      _.assert( dst.hasShape( src ) );
      src.atomEach( function( it )
      {
        dst.atomSet( it.indexNd, it.atom );
      });

    }
    else
    {
      var extract = it.src.extractNormalized();
      var newIteration = it.iterationNew();
      newIteration.select( 'buffer' );
      newIteration.src = extract.buffer;
      dst.buffer = _._cloneAct( newIteration );
      dst.offset = extract.offset;
      dst.strides = extract.strides;
    }
  }

  return dst;
}

_traverseAct.iterationDefaults = Object.create( _._cloner.iterationDefaults );
// _traverseAct.iterationDefaults.resetting = 0;
_traverseAct.defaults = _.mapSupplementOwn( Object.create( _._cloner.defaults ),_traverseAct.iterationDefaults );

//

function _copy( src,resetting )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  var it = _._cloner( self._traverseAct,{ src : src, dst : self, /*resetting : resetting,*/ technique : 'object' } );

  self._traverseAct( it );

  return it.dst;
}

//

function copy( src )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  return self._copy( src,0 );
}

//

function copyResetting( src )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  return self._copy( src,1 );
}

//

function copyFromScalar( src )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.numberIs( src ) );

  self.atomEach( ( it ) => self.atomSet( it.indexNd,src ) );

  return self;
}

//

function copyFromBuffer( src )
{
  var self = this;
  self._bufferCopy( src );
  return self;
}

//

function clone()
{
  var self = this;

  _.assert( arguments.length === 0 );

  var dst = _.Copyable.prototype.clone.call( self );

  if( dst.buffer === self.buffer )
  dst[ bufferSymbol ] = _.arraySlice( dst.buffer );

  return dst;
}

//

function copyTo( dst,src )
{

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( dst === src )
  return dst;

  var odst = dst;
  var dstDims = Self.dimsOf( dst );
  var srcDims = Self.dimsOf( src );

  _.assert( _.arrayIdentical( srcDims,dstDims ),'(-src-) and (-dst-) should have same dimensions' );
  _.assert( !_.instanceIs( this ) )

  if( !_.spaceIs( src ) )
  {

    src = vector.from( src );
    if( _.arrayLike( dst ) )
    dst = vector.from( dst );

    if( _.vectorIs( dst ) )
    for( var s = 0 ; s < src.length ; s += 1 )
    dst.eSet( s,src.eGet( s ) )
    else if( _.spaceIs( dst ) )
    for( var s = 0 ; s < src.length ; s += 1 )
    dst.atomSet( [ s,0 ],src.eGet( s ) )
    else _.assert( 0,'unknown type of (-dst-)',_.strTypeOf( dst ) );

    return odst;
  }
  else
  {

    var dstDims = Self.dimsOf( dst );
    var srcDims = Self.dimsOf( src );

    if( _.spaceIs( dst ) )
    src.atomEach( function( it )
    {
      dst.atomSet( it.indexNd , it.atom );
    });
    else if( _.vectorIs( dst ) )
    src.atomEach( function( it )
    {
      dst.eSet( it.indexFlat , it.atom );
    });
    else if( _.arrayLike( dst ) )
    src.atomEach( function( it )
    {
      dst[ it.indexFlat ] = it.atom;
    });
    else _.assert( 0,'unknown type of (-dst-)',_.strTypeOf( dst ) );

  }

  return odst;
}

//

function extractNormalized()
{
  var self = this;
  var result = Object.create( null );

  _.assert( arguments.length === 0 );

  result.buffer = _.arrayMakeSimilar( self.buffer , self.atomsPerSpace );
  result.offset = 0;
  result.strides = self.stridesForDimensions( self.dims,self.inputTransposing );

  self.atomEach( function( it )
  {
    var i = self._flatAtomIndexFromIndexNd( it.indexNd,result.strides );
    result.buffer[ i ] = it.atom;
  });

  return result;
}

// --
// size in bytes
// --

function _sizeGet()
{
  var result = this.sizeOfAtom*this.atomsPerSpace;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfElementGet()
{
  var result = this.sizeOfAtom*this.atomsPerElement;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfElementStrideGet()
{
  var result = this.sizeOfAtom*this.strideOfElement;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfColGet()
{
  var result = this.sizeOfAtom*this.atomsPerCol;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfColStrideGet()
{
  var result = this.sizeOfAtom*this.strideOfCol;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfRowGet()
{
  var result = this.sizeOfAtom*this.atomsPerRow;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfRowStrideGet()
{
  var result = this.sizeOfAtom*this.strideOfRow;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfAtomGet()
{
  _.assert( this.buffer );
  var result = this.buffer.BYTES_PER_ELEMENT;
  _.assert( result >= 0 );
  return result;
}

// --
// size in atoms
// --

function _atomsPerElementGet()
{
  var self = this;
  return self[ atomsPerElementSymbol ];
}

//

function _atomsPerColGet()
{
  var self = this;
  var result = self.dims[ 0 ];
  _.assert( result >= 0 );
  return result;
}

//

function _atomsPerRowGet()
{
  var self = this;
  var result = self.dims[ 1 ];
  _.assert( result >= 0 );
  return result;
}

//

function _nrowGet()
{
  var self = this;
  var result = self.dims[ 0 ];
  _.assert( result >= 0 );
  return result;
}

//

function _ncolGet()
{
  var self = this;
  var result = self.dims[ 1 ];
  _.assert( result >= 0 );
  return result;
}

//

function _atomsPerSpaceGet()
{
  var self = this;
  var result = self.length === Infinity ? self.atomsPerElement : self.length * self.atomsPerElement;
  _.assert( _.numberIsFinite( result ) );
  _.assert( result >= 0 );
  return result;
}

//

function atomsPerSpaceForDimensions( dims )
{
  var result = 1;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( dims ) );

  for( var d = dims.length-1 ; d >= 0 ; d-- )
  {
    _.assert( dims[ d ] >= 0 )
    result *= dims[ d ];
  }

  return result;
}

//

function nrowOf( src )
{
  if( src instanceof Self )
  return src.dims[ 0 ];
  _.assert( src.length >= 0 );
  return src.length;
}

//

function ncolOf( src )
{
  if( src instanceof Self )
  return src.dims[ 1 ];
  _.assert( src.length >= 0 );
  return 1;
}

//

function dimsOf( src )
{
  if( src instanceof Self )
  return src.dims.slice();
  var result = [ 0,1 ];
  _.assert( src.length >= 0 );
  result[ 0 ] = src.length;
  return result;
}

// --
// stride
// --

function _lengthGet()
{
  return this[ lengthSymbol ];
}

//

function _occupiedRangeGet()
{
  return this[ occupiedRangeSymbol ];
}

//

function _stridesEffectiveGet()
{
  return this[ stridesEffectiveSymbol ];
}

//

function _stridesSet( src )
{
  var self = this;

  // _.assert( _.arrayLike( src ) || _.numberIs( src ) || src === null );
  _.assert( _.arrayLike( src ) || src === null );

  if( _.arrayLike( src ) )
  src = _.arraySlice( src );

  self[ stridesSymbol ] = src;

  self._sizeChanged();

}

//

function _strideOfElementGet()
{
  return this._stridesEffective[ this._stridesEffective.length-1 ];
}

//

function _strideOfColGet()
{
  return this._stridesEffective[ 1 ];
}

//

function _strideInColGet()
{
  return this._stridesEffective[ 0 ];
}

//

function _strideOfRowGet()
{
  return this._stridesEffective[ 0 ];
}

//

function _strideInRowGet()
{
  return this._stridesEffective[ 1 ];
}

//

function stridesForDimensions( dims,transposing )
{

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.arrayIs( dims ) );
  _.assert( _.boolLike( transposing ) );
  _.assert( dims[ 0 ] >= 0 );
  _.assert( dims[ dims.length-1 ] >= 0 );

  var strides = dims.slice();

  if( transposing )
  {
    strides.push( 1 );
    strides.splice( 0,1 );
    _.assert( strides[ 1 ] > 0 );
    _.assert( strides[ strides.length-1 ] > 0 );
    for( var i = strides.length-2 ; i >= 0 ; i-- )
    strides[ i ] = strides[ i ]*strides[ i+1 ];
  }
  else
  {
    strides.splice( strides.length-1,1 );
    strides.unshift( 1 );
    _.assert( strides[ 0 ] > 0 );
    _.assert( strides[ 1 ] >= 0 );
    for( var i = 1 ; i < strides.length ; i++ )
    strides[ i ] = strides[ i ]*strides[ i-1 ];
  }

  /* */

  if( dims[ 0 ] === Infinity )
  strides[ 0 ] = 0;
  if( dims[ 1 ] === Infinity )
  strides[ 1 ] = 0;

  return strides;
}

//

function stridesRoll( strides )
{

  _.assert( arguments.length === 1, 'expects single argument' ); debugger;

  for( var s = strides.length-2 ; s >= 0 ; s-- )
  strides[ s ] = strides[ s+1 ]*strides[ s ];

  return strides;
}

// --
// buffer
// --

function _bufferSet( src )
{
  var self = this;

  if( self[ bufferSymbol ] === src )
  return;

  if( _.numberIs( src ) )
  src = this.array.makeArrayOfLength([ src ]);

  _.assert( _.arrayLike( src ) || src === null );

  self[ bufferSymbol ] = src;

  if( !self._changing[ 0 ] )
  self[ dimsSymbol ] = null;

  self._sizeChanged();

}

//

function _offsetSet( src )
{
  var self = this;

  _.assert( _.numberIs( src ) );

  self[ offsetSymbol ] = src;

  self._sizeChanged();

}

//

function _bufferCopy( src )
{
  var self = this;
  self._changeBegin();

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayLike( src ) );
  _.assert( self.atomsPerSpace === src.length,'space',self.dims,'should have',self.atomsPerSpace,'atoms, but got',src.length );

  // /*
  //  !!! maybe problem if stride is not regular
  // */

  // if( !( src instanceof Array ) && src.constructor !== self.buffer.constructor )
  // {
  //   self[ offsetSymbol ] = 0;
  //   self[ bufferSymbol ] = self.array.makeSimilar( src,src.length );
  // }

  // var i = 0;
  // for( var c = 0 ; c < self.atomsPerCol ; c++ )
  // for( var r = 0 ; r < self.atomsPerRow ; r++ )
  // {
  //   self.atomSet( [ c,r ],src[ i ] );
  //   i += 1;
  // }

  self.atomEach( function( it )
  {
    self.atomSet( it.indexNd, src[ it.indexFlatRowFirst ] );
  });

  self._changeEnd();
  return self;
}

//

function bufferCopyTo( dst )
{
  var self = this;
  var atomsPerSpace = self.atomsPerSpace;

  if( !dst )
  dst = _.arrayMakeSimilar( self.buffer, atomsPerSpace );

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.arrayLike( dst ) );
  _.assert( atomsPerSpace === dst.length,'space',self.dims,'should have',atomsPerSpace,'atoms, but got',dst.length );

  throw _.err( 'not tested' );

  self.atomEach( function( it )
  {
    dst[ it.indexFlat ] = it.atom;
  });

  return dst;
}

// --
// reshape
// --

function _changeBegin()
{
  var self = this;

  self._changing[ 0 ] += 1;

}

//

function _changeEnd()
{
  var self = this;

  self._changing[ 0 ] -= 1;
  self._sizeChanged();

}

//

function _sizeChanged()
{
  var self = this;

  if( self._changing[ 0 ] )
  return;

  self._adjust();

}

//

function _adjust()
{
  var self = this;

  self._adjustVerify();
  self._adjustAct();
  self._adjustValidate();

}

//

function _adjustAct()
{
  var self = this;
  var changed = false;

  // if( self.name === 'aColor' && self.buffer && !self.isInvariant )
  // debugger;

  // if( _.entityIdentical( self._stridesEffective,[ 1,0 ] ) )
  // debugger;

  self._changing[ 0 ] += 1;

  /* adjust breadth */

  if( _.numberIs( self.breadth ) )
  {
    debugger;
    self.breadth = [ self.breadth ];
    changed = true;
  }

  /* strides */

  if( _.numberIs( self.strides ) )
  {
    debugger;
    var strides = _.dup( 1,self.breadth.length+1 );
    strides[ strides.length-1 ] = self.strides;
    self.strides = self.stridesRoll( strides );
    changed = true;
  }

  self[ stridesEffectiveSymbol ] = null;

  if( self.strides )
  {
    self[ stridesEffectiveSymbol ] = self.strides;
  }

  /* dims */

  _.assert( self.dims === null || _.arrayLike( self.dims ) );

  // if( self.buffer && self.buffer.length === 0 && self.offset === 0 && self.inputTransposing === 0 )
  // debugger;

  if( !self.dims )
  {
    if( self._dimsWas )
    {
      // self[ dimsSymbol ] = self._dimsFromDimsWithoutLength( self.breadth, self.buffer, self.offset );

      // _.assert( self.breadth );
      _.assert( self._dimsWas );
      // _.assert( self._dimsWas.length === self.breadth.length+1 );
      _.assert( _.arrayIs( self._dimsWas ) );
      // _.assert( _.arrayIs( self.breadth ) );
      _.assert( _.arrayLike( self.buffer ) );
      _.assert( self.offset >= 0 );

      var dims = self._dimsWas.slice();
      dims[ self.growingDimension ] = 1;
      var ape = _.avector.reduceToProduct( dims );
      var l = ( self.buffer.length - self.offset ) / ape;
      dims[ self.growingDimension ] = l;
      self[ dimsSymbol ] = dims;

      // var dims = self.breadth.slice();
      // dims.push( l );

      // _.assert( self.breadth.length === 1,'not tested' );
      _.assert( l >= 0 );
      _.assert( _.numberIsInt( l ) );

    }
    else if( self.strides )
    {
      _.assert( 0,'Cant deduce dims from strides' );
      // debugger;
      // // _.assert( 0,'not tested' );
      // _.assert( _.arrayLike( self.strides ) );
      // _.assert( self.strides[ 0 ] > 1,'not tested' );
      // var dims = self[ dimsSymbol ] = self.strides.slice();
      // dims.splice( 0,1 );
      // changed = true;
    }
    else
    {
      _.assert( _.arrayLike( self.buffer ),'expects buffer' );
      if( self.buffer.length - self.offset > 0 )
      {
        self[ dimsSymbol ] = [ self.buffer.length - self.offset,1 ];
        if( !self._stridesEffective )
        self[ stridesEffectiveSymbol ] = [ 1,self.buffer.length - self.offset ];
      }
      else
      {
        self[ dimsSymbol ] = [ 1,0 ];
        if( !self._stridesEffective )
        self[ stridesEffectiveSymbol ] = [ 1,1 ];
      }
      changed = true;
    }
  }

  _.assert( self.dims );

  self._dimsWas = self.dims.slice();

  self[ breadthSymbol ] = self.dims.slice( 0,self.dims.length-1 );
  self[ lengthSymbol ] = self.dims[ self.dims.length-1 ];

  /* strides */

  // if( self.buffer && self.buffer.length === 0 && self.offset === 0 && self.dims && self.dims[ 0 ] === 1 && self.dims[ 1 ] === 0 )
  // debugger;

  if( !self._stridesEffective )
  {

    _.assert( _.boolLike( self.inputTransposing ) );
    _.assert( self.dims[ 0 ] >= 0 );
    _.assert( self.dims[ self.dims.length-1 ] >= 0 );

    var strides = self[ stridesEffectiveSymbol ] = self.stridesForDimensions( self.dims,self.inputTransposing );

  }

  _.assert( self._stridesEffective.length >= 2 );

  /* atoms per element */

  _.assert( self.breadth.length === 1,'not tested' );
  self[ atomsPerElementSymbol ] = _.avector.reduceToProduct( self.breadth );

  /* buffer region */

  var dims = self.dims;
  var offset = self.offset;
  var occupiedRange = [ 0,0 ];
  var last;

  if( self.length !== 0 )
  {

    for( var s = 0 ; s < self._stridesEffective.length ; s++ )
    {
      if( dims[ s ] === Infinity )
      continue;

      last = dims[ s ] > 0 ? self._stridesEffective[ s ]*( dims[ s ]-1 ) : 0;

      _.assert( last >= 0, 'not tested' );

      occupiedRange[ 1 ] += last;

      // occupiedRange[ 0 ] = min( occupiedRange[ 0 ],stride );
      // occupiedRange[ 1 ] = max( occupiedRange[ 1 ],stride );
    }

  }

  occupiedRange[ 0 ] += offset;
  occupiedRange[ 1 ] += offset;

  occupiedRange[ 1 ] += 1;

  // if( self.atomsPerSpace > 0 )
  // occupiedRange[ 1 ] = max( occupiedRange[ 1 ],1 );

  // console.log( 'occupiedRange',occupiedRange );

  self[ occupiedRangeSymbol ] = occupiedRange;

  /* done */

  _.entityFreeze( self.dims );
  _.entityFreeze( self.breadth );
  _.entityFreeze( self._stridesEffective );

  self._changing[ 0 ] -= 1;

}

//

function _adjustVerify()
{
  var self = this;

  _.assert( _.arrayLike( self.buffer ),'space needs buffer' );
  _.assert( _.arrayLike( self.strides ) || self.strides === null );
  // _.assert( _.arrayLike( self.strides ) || _.numberIs( self.strides ) || self.strides === null );
  _.assert( _.numberIs( self.offset ),'space needs offset' );

}

//

function _adjustValidate()
{
  var self = this;

  _.assert( self.breadth );
  _.assert( self.dims.length === self.breadth.length+1 );
  _.assert( _.arrayIs( self.dims ) );
  _.assert( _.arrayIs( self.breadth ) );

  _.assert( self.length >= 0 );
  _.assert( self.atomsPerElement >= 0 );
  _.assert( self.strideOfElement >= 0 );

  _.assert( _.arrayLike( self.buffer ) );
  _.assert( _.arrayLike( self.breadth ) );

  _.assert( _.arrayLike( self._stridesEffective ) );
  _.assert( _.numbersAreInt( self._stridesEffective ) );
  _.assert( _.numbersArePositive( self._stridesEffective ) );
  _.assert( self._stridesEffective.length >= 2 );

  _.assert( _.numbersAreInt( self.dims ) );
  _.assert( _.numbersArePositive( self.dims ) );

  _.assert( _.numberIsInt( self.length ) );
  _.assert( self.length >= 0 );
  _.assert( self.dims[ self.dims.length-1 ] === self.length );

  _.assert( self.breadth.length+1 === self._stridesEffective.length );

  if( Config.debug )
  for( var d = 0 ; d < self.dims.length-1 ; d++ )
  _.assert( self.dims[ d ] >= 0 );

  if( Config.debug )
  if( self.atomsPerSpace > 0 && _.numberIsFinite( self.length ) )
  for( var d = 0 ; d < self.dims.length ; d++ )
  _.assert( self.offset + ( self.dims[ d ]-1 )*self._stridesEffective[ d ] <= self.buffer.length,'out of bound' );

}

//

// function _dimsFromDimsWithoutLength( breadth, buffer, offset )
// {
//
//   _.assert( arguments.length === 3, 'expects exactly three argument' );
//   _.assert( _.arrayIs( breadth ) );
//   _.assert( _.arrayLike( buffer ) );
//   _.assert( offset >= 0 );
//
//   var ape = _.avector.reduceToProduct( breadth );
//   var l = ( buffer.length - offset ) / ape;
//   var dims = breadth.slice();
//   dims.push( l );
//
//   _.assert( breadth.length === 1,'not tested' );
//   _.assert( l >= 0 );
//   _.assert( _.numberIsInt( l ) );
//
//   return dims;
// }

//

function _breadthGet()
{
  var self = this;
  return self[ breadthSymbol ];
}

//

function _breadthSet( breadth )
{
  var self = this;

  if( _.numberIs( breadth ) )
  breadth = [ breadth ];
  else if( _.bufferTypedIs( breadth ) )
  breadth = _.arrayFrom( breadth );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( breadth === null || _.arrayIs( breadth ),'expects array (-breadth-) but got',_.strTypeOf( breadth ) );

  if( breadth === self.breadth )
  return;

  if( breadth !== null && self.breadth !== null )
  if( _.arrayIdentical( self.breadth,breadth ) )
  return;

  self._changeBegin();

  if( breadth === null )
  {
    debugger;
    if( self[ dimsSymbol ] === null )
    debugger;
    self[ breadthSymbol ] = null
    if( self[ dimsSymbol ] === null )
    self._dimsWas = null;
  }
  else
  {
    var _dimsWas = breadth.slice();
    _dimsWas.push( self._dimsWas ? self._dimsWas[ self._dimsWas.length-1 ] : 0 );
    self[ breadthSymbol ] = _.entityFreeze( breadth.slice() );
    self[ dimsSymbol ] = null;
    self._dimsWas = _dimsWas;
  }

  self._changeEnd();
}

//

function _dimsSet( src )
{
  var self = this;

  // console.log( '_dimsSet' );

  _.assert( arguments.length === 1, 'expects single argument' );

  if( src )
  {
    if( src[ 0 ] === Infinity )
    debugger;

    _.assert( _.arrayIs( src ) );
    _.assert( src.length >= 2 );
    _.assert( _.numbersAreInt( src ) );
    _.assert( src[ 0 ] >= 0 );
    _.assert( src[ src.length-1 ] >= 0 );
    self[ dimsSymbol ] = _.entityFreeze( src.slice() );
    self[ breadthSymbol ] = _.entityFreeze( src.slice( 0,src.length-1 ) );

    // if( src[ 1 ] === Infinity )
    // debugger;
    // if( src[ 1 ] === Infinity )
    // self[ stridesEffectiveSymbol ] = _.arraySet( _.arraySlice( self[ stridesEffectiveSymbol ] ),1,Infinity );

  }
  else
  {
    self[ dimsSymbol ] = null;
    self[ breadthSymbol ] = null;
  }

  _.assert( self[ dimsSymbol ] === null || _.numbersAreInt( self[ dimsSymbol ] ) );

  self._sizeChanged();

  return src;
}

//

// function expand( left,right )
function expand( expand )
{
  var self = this;

  // if( left === null )
  // left = _.dup( 0,self.dims.length );
  // if( right === null )
  // right = _.dup( 0,self.dims.length );

  /* */

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( expand.length === self.dims.length );
  // _.assert( left.length === self.dims.length );
  // _.assert( right.length === self.dims.length );

  /* */

  var dims = self.dims.slice();
  for( var i = 0 ; i < dims.length ; i++ )
  {
    if( !expand[ i ] )
    {
      expand[ i ] = [ 0,0 ];
    }
    else if( _.numberIs( expand[ i ] ) )
    {
      expand[ i ] = [ expand[ i ],expand[ i ] ];
    }
    else
    {
      expand[ i ][ 0 ] = expand[ i ][ 0 ] || 0;
      expand[ i ][ 1 ] = expand[ i ][ 1 ] || 0;
    }
    _.assert( expand[ i ].length === 2 );
    _.assert( -expand[ i ][ 0 ] <= dims[ i ] );
    _.assert( -expand[ i ][ 1 ] <= dims[ i ] );
    dims[ i ] += expand[ i ][ 0 ] + expand[ i ][ 1 ];
  }

  if( self.hasShape( dims ) )
  return self;

  var atomsPerSpace = self.atomsPerSpaceForDimensions( dims );
  var strides = self.stridesForDimensions( dims,0 );
  var buffer = _.arrayMakeSimilarZeroed( self.buffer,atomsPerSpace );

  /* move data */

  self.atomEach( function( it )
  {
    for( var i = 0 ; i < dims.length ; i++ )
    {
      it.indexNd[ i ] += expand[ i ][ 0 ];
      if( it.indexNd[ i ] < 0 || it.indexNd[ i ] >= dims[ i ] )
      return;
    }
    var indexFlat = Self._flatAtomIndexFromIndexNd( it.indexNd , strides );
    _.assert( indexFlat >= 0 );
    _.assert( indexFlat < buffer.length );
    buffer[ indexFlat ] = it.atom;
  });

  /* copy */

  self.copyResetting
  ({
    inputTransposing : 0,
    offset : 0,
    buffer : buffer,
    dims : dims,
    strides : null,
  });

  return self;
}

//

function shapesAreSame( ins1,ins2 )
{
  _.assert( !_.instanceIs( this ) );

  var dims1 = this.dimsOf( ins1 );
  var dims2 = this.dimsOf( ins2 );

  return _.arrayIdentical( dims1,dims2 );
}

//

function hasShape( src )
{
  var self = this;

  // src = Self.dimsOf( src );

  if( src instanceof Self )
  src = src.dims;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( src ) );

  return _.arrayIdentical( self.dims,src );
}

//

function isSquare()
{
  var self = this;
  _.assert( arguments.length === 0 );
  return self.dims[ 0 ] === self.dims[ 1 ];
}

// --
// etc
// --

function flatAtomIndexFrom( indexNd )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var result = self._flatAtomIndexFromIndexNd( indexNd,self._stridesEffective );

  return result + self.offset;
}

//

function _flatAtomIndexFromIndexNd( indexNd,strides )
{
  var result = 0;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.arrayIs( indexNd ) );
  _.assert( _.arrayIs( strides ) );
  _.assert( indexNd.length === strides.length );

  for( var i = 0 ; i < indexNd.length ; i++ )
  {
    result += indexNd[ i ]*strides[ i ];
  }

  return result;
}

//

function flatGranuleIndexFrom( indexNd )
{
  var self = this;
  var result = 0;
  var stride = 1;
  var d = self._stridesEffective.length-indexNd.length;

  debugger;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( indexNd.length <= self._stridesEffective.length );

  var f = self._stridesEffective.length - indexNd.length;
  // for( var i = indexNd.length-1 ; i >= 0 ; i-- )
  for( var i = f ; i < indexNd.length ; i++ )
  {
    stride = self._stridesEffective[ i ];
    result += indexNd[ i-f ]*stride;
  }

  return result;
}

//

function transpose()
{
  var self = this;
  self._changeBegin();

  var dims = self.dims.slice();
  var strides = self._stridesEffective.slice();

  _.assert( arguments.length === 0 );
  _.assert( dims.length >= 2 );
  _.assert( strides.length >= 2 );
  _.assert( strides.length === dims.length );

  // _.arraySwap( dims,dims.length-1,dims.length-2 );
  // _.arraySwap( strides,strides.length-1,strides.length-2 );

  _.arraySwap( dims,0,1 );
  _.arraySwap( strides,0,1 );

  self.strides = strides;
  self.dims = dims;

  self._changeEnd();
  return self;
}

//

function equalWith( ins,o )
{
  debugger; xxx
  var it = equalWith.lookContinue( equalWith, arguments );
  var result = this._equalAre( it );
  return result;
  // _entityEqualIteratorMake

  // var self = this;
  // var o = _._entityEqualIteratorMake( o || Object.create( null ) );
  // _.assert( arguments.length <= 2 );
  // return self._equalAre( self,ins,o );
}

_.routineSupplement( equalWith, _._entityEqual );

//

function _equalAre( it )
{

  _.assert( arguments.length === 1, 'expects exactly three argument' );
  _.assert( it.context.onNumbersAreEqual );

  debugger;
  it.looking = false;

  if( !( it.src2 instanceof Self ) )
  {
    it.result = false;
    return it.result;
  }

  if( it.src.length !== it.src2.length )
  {
    it.result = false;
    return it.result;
  }

  if( it.src.buffer.constructor !== it.src2.buffer.constructor )
  {
    it.result = false;
    return it.result;
  }

  if( !_.arrayIdentical( it.src.breadth,it.src2.breadth )  )
  {
    it.result = false;
    return it.result;
  }

  it.result = it.src.atomWhile( function( atom,indexNd,indexFlat )
  {
    var atom2 = it.src2.atomGet( indexNd );
    return it.context.onNumbersAreEqual( atom,atom2 );
  });

  return it.result;
}

_.routineSupplement( _equalAre, _._entityEqual );

//
//
// function identicalWith( src )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//
//   if( !( src instanceof Self ) )
//   return false;
//
//   if( self.length !== src.length )
//   return false;
//
//   if( self.buffer.constructor !== src.buffer.constructor )
//   return false;
//
//   debugger;
//
//   if( !_.arrayIdentical( self.breadth,src.breadth )  )
//   return false;
//
//   debugger;
//   return _.arrayIdentical( self.buffer,self.buffer );
// }
//
//

function is( src )
{
  _.assert( arguments.length === 1, 'expects single argument' );
  return _.spaceIs( src );
}

//

function toStr( o )
{
  var self = this;
  var result = '';

  var o = o || Object.create( null );
  _.routineOptions( toStr,o );

  var l = self.dims[ 0 ];
  var atomsPerRow,atomsPerCol;
  var col,row;
  var m,c,r,e;

  var isInt = true;
  self.atomEach( function( it )
  {
    isInt = isInt && _.numberIsInt( it.atom );
  });

  /* */

  function eToStr()
  {
    var e = row.eGet( c );

    if( isInt )
    {
      if( !o.usingSign || e < 0 )
      result += e.toFixed( 0 );
      else
      result += '+' + e.toFixed( 0 );
    }
    else
    {
      result += e.toFixed( o.precision );
    }

    // if( c < atomsPerRow-1 )
    result += ', ';

  }

  /* */

  function rowToStr()
  {

    if( m === undefined )
    row = self.rowVectorGet( r );
    else
    row = self.rowVectorOfMatrixGet( [ m ],r );

    if( atomsPerRow === Infinity )
    {
      e = 0;
      eToStr();
      result += '*Infinity';
    }
    else for( c = 0 ; c < atomsPerRow ; c += 1 )
    eToStr();

  }

  /* */

  function matrixToStr( m )
  {

    atomsPerRow = self.atomsPerRow;
    atomsPerCol = self.atomsPerCol;

    if( atomsPerCol === Infinity )
    {
      r = 0;
      rowToStr( 0 );
      result += ' **Infinity';
    }
    else for( r = 0 ; r < atomsPerCol ; r += 1 )
    {
      rowToStr( r );
      if( r < atomsPerCol - 1 )
      result += '\n' + o.tab;
    }

  }

  /* */

  if( self.dims.length === 2 )
  {

    matrixToStr();

  }
  else if( self.dims.length === 3 )
  {

    for( m = 0 ; m < l ; m += 1 )
    {
      result += 'Slice ' + m + ' :\n';
      matrixToStr( m );
    }

  }
  else _.assert( 0, 'not implemented' );

  return result;
}

toStr.defaults =
{
  tab : '',
  precision : 3,
  usingSign : 1,
}

toStr.defaults.__proto__ = _.toStr.defaults;

//

function _bufferFrom( src )
{
  var proto = this.Self.prototype;
  var dst = src;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayLike( src ) || _.vectorIs( src ) );

  if( !_.constructorIsBuffer( proto.array.ArrayType ) )
  return dst;

  if( _.vectorIs( dst ) && _.arrayIs( dst._vectorBuffer ) )
  {
    dst = this.array.makeArrayOfLength( src.length );
    for( var i = 0 ; i < src.length ; i++ )
    dst[ i ] = src.eGet( i );
  }
  else if( _.arrayIs( dst ) )
  {
    dst = proto.array.arrayFromCoercing( dst );
  }

  return dst;
}

//

function bufferNormalize()
{
  var self = this;

  _.assert( arguments.length === 0 );

  var buffer = _.arrayMakeSimilar( self.buffer,self.atomsPerSpace );

  var i = 0;
  self.atomEach( function( it )
  {
    buffer[ i ] = it.atom;
    i += 1;
  });

  self.copy
  ({
    buffer : buffer,
    offset : 0,
    inputTransposing : 0,
  });

}

//

function subspace( subspace )
{
  var self = this;

  _.assert( arguments.length === 1,'expects single argument' );
  _.assert( _.arrayIs( subspace ),'expects array (-subspace-)' );
  _.assert( subspace.length <= self.dims.length,'expects array (-subspace-) of length of self.dims' );

  for( var s = subspace.length ; s < self.dims.length ; s++ )
  subspace.unshift( all );

  var dims = [];
  var strides = [];
  var stride = 1;
  var offset = Infinity;

  for( var s = 0 ; s < subspace.length ; s++ )
  {
    if( subspace[ s ] === all )
    {
      dims[ s ] = self.dims[ s ];
      strides[ s ] = self._stridesEffective[ s ];
    }
    else if( _.numberIs( subspace[ s ] ) )
    {
      dims[ s ] = 1;
      strides[ s ] = self._stridesEffective[ s ];
      offset = Math.min( self._stridesEffective[ s ]*subspace[ s ],offset );
    }
    else if( _.arrayIs( subspace[ s ] ) )
    {
      _.assert( _.arrayIs( subspace[ s ] ) && subspace[ s ].length === 2 );
      dims[ s ] = subspace[ s ][ 1 ] - subspace[ s ][ 0 ];
      strides[ s ] = self._stridesEffective[ s ];
      offset = Math.min( self._stridesEffective[ s ]*subspace[ s ][ 0 ],offset );
    }
    else _.assert( 0,'unknown subspace request' );
  }

  if( offset === Infinity )
  offset = 0;
  offset += self.offset;

  var result = new Self
  ({
    buffer : self.buffer,
    offset : offset,
    strides : strides,
    dims : dims,
    inputTransposing : self.inputTransposing,
  });

  return result;
}

// --
// iterator
// --

function atomWhile( o )
{
  var self = this;
  var result = true;

  if( _.routineIs( o ) )
  o = { onAtom : o }

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( atomWhile,o );
  _.assert( _.routineIs( o.onAtom ) );

  var dims = self.dims;

  function handleEach( indexNd,indexFlat )
  {
    var value = self.atomGet( indexNd );
    result = o.onAtom.call( self,value,indexNd,indexFlat,o );
    return result;
  }

  _.eachInMultiRange
  ({
    ranges : dims,
    onEach : handleEach,
  })

  return result;
}

atomWhile.defaults =
{
  onAtom : null,
}

//

function atomEach( onAtom,args )
{
  var self = this;
  var dims = self.dims;

  if( args === undefined )
  args = [];

  _.assert( arguments.length <= 2 );
  _.assert( self.dims.length === 2,'not tested' );
  _.assert( _.arrayIs( args ) );
  _.assert( onAtom.length === 1 );

  args.unshift( null );
  args.unshift( null );

  var dims0 = dims[ 0 ];
  var dims1 = dims[ 1 ];

  if( dims1 === Infinity )
  dims1 = 1;

  var it = Object.create( null );
  it.args = args;
  var indexFlat = 0;
  for( var c = 0 ; c < dims1 ; c++ )
  for( var r = 0 ; r < dims0 ; r++ )
  {
    it.indexNd = [ r,c ];
    it.indexFlat = indexFlat;
    it.indexFlatRowFirst = r*dims[ 1 ] + c;
    it.atom = self.atomGet( it.indexNd );
    onAtom.call( self,it );
    indexFlat += 1;
  }

  return self;
}

//

function atomWiseReduceWithFlatVector( onVector )
{
  var self = this;
  var result;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( self.strideOfElement === self.atomsPerElement );

  debugger;

  var result = onVector( self.asVector() );

  return result;
}

//

function atomWiseReduceWithAtomHandler( onBegin,onAtom,onEnd )
{
  var self = this;
  var result;

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( self.dims.length === 2, 'not implemented' );

  var op = onBegin
  ({
    args : [ self ],
    container : self,
    filter : null,
  });

  for( var c = 0 ; c < self.atomsPerCol ; c++ )
  for( var r = 0 ; r < self.atomsPerRow ; r++ )
  {
    op.key = [ c,r ];
    op.element = self.atomGet([ c,r ]);
    onAtom( op );
  }

  onEnd( op );

  return op.result;
}

//

function atomWiseWithAssign( onAtom,args )
{
  var self = this;
  var result;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( self.dims.length === 2, 'not implemented' );

  var op = Object.create( null );
  op.key = -1;
  op.args = args;
  op.dstContainer = self;
  op.dstElement = null;
  op.srcElement = null;
  Object.preventExtensions( op );

  for( var c = 0 ; c < self.atomsPerCol ; c++ )
  for( var r = 0 ; r < self.atomsPerRow ; r++ )
  {
    op.key = [ c,r ];
    op.dstElement = self.atomGet( op.key );
    onAtom.call( self,op );
  }

  return self;
}

//

function atomWiseHomogeneous( o )
{
  var proto = this;
  var newDst = false;

  _.routineOptions( atomWiseHomogeneous,o );

  if( o.dst !== undefined && o.dst !== _.nothing )
  {
    if( o.usingDstAsSrc )
    o.args.unshift( o.dst );
  }
  else
  {
    o.dst = o.args[ 0 ]
  }

  /* preliminary analysis */

  var dims = null;
  for( var s = 0 ; s < o.args.length ; s++ )
  {
    var src = o.args[ s ];
    if( src instanceof Self )
    if( dims )
    _.assert( _.arrayIdentical( src.dims,dims ) )
    else
    dims = src.dims;
  }

  _.assert( dims );

  /* default handlers*/

  if( !o.onVectorsBegin )
  o.onVectorsBegin = function handleVectorsBeing()
  {

    debugger;

    var op = Object.create( null );
    op.key = -1;
    // op.args = [ o.dst,o.srcs ];
    // op.dstContainer = o.dst;
    op.args = null;
    op.dstContainer = null;
    op.dstElement = null;
    op.srcContainerIndex = -1;
    op.srcContainer = null;
    op.srcElement = null;
    Object.preventExtensions( op );

    return op;
  }

  if( o.onAtomsBegin )
  debugger;
  if( !o.onAtomsBegin )
  o.onAtomsBegin = function handleAtomsBeing( op )
  {

    // debugger
    // op.dstElement = 0;

  }

  /* dst */

  // debugger;
  if( o.reducing )
  {
    _.assert( !o.usingDstAsSrc );
    o.srcs = o.args.slice( 0 );
    o.dst = null;
  }
  else if( _.nothingIs( o.dst ) )
  {
    o.srcs = o.args.slice( 1 );
    o.dst = o.args[ 0 ];
    /*o.dst = proto.makeZero( dims );*/
    o.dst = o.args[ 0 ] = wSpace.from( o.dst,dims );
  }
  else
  {
    o.srcs = o.args.slice( o.usingDstAsSrc ? 0 : 1 );
  }

  var fsrc = o.srcs[ 0 ];

  /* srcs allocation */

  for( var s = 0 ; s < o.srcs.length ; s++ )
  {
    var src = o.srcs[ s ] = wSpace.from( o.srcs[ s ],dims );
    _.assert( src instanceof Self );
  }

  /* verification */

  _.assert( !proto.instanceIs() );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( o.dst instanceof Self || o.reducing );
  _.assert( !o.dst || o.dst.dims.length === 2, 'not implemented' );
  _.assert( !o.dst || _.arrayIdentical( o.dst.dims,dims ) )
  _.assert( fsrc instanceof Self );
  _.assert( fsrc.dims.length === 2, 'not implemented' );
  _.assert( _.arrayIdentical( fsrc.dims,dims ) )

  /* */

  var op = o.onVectorsBegin.call( o.dst,op );

  op.args = o.args;
  op.dstContainer = o.dst;
  op.srcContainers = o.srcs;

  _.assert( op.srcContainers.length > 0 );

  /* */

  var brk = 0;
  for( var c = 0 ; c < fsrc.atomsPerCol ; c++ )
  {

    for( var r = 0 ; r < fsrc.atomsPerRow ; r++ )
    {

      op.key = [ c,r ];
      // op.dstElement = o.dst.atomGet( op.key );

      // debugger;
      op.dstElement = fsrc.atomGet( op.key );

      // if( o.onAtomsBegin )
      o.onAtomsBegin( op );

      _.assert( _.numberIs( op.dstElement ) );

      // op.dstElement = op.dstContainer.atomGet( op.key );
      // op.dstElement = op.srcContainers[ 0 ].atomGet( op.key );

      if( op.srcContainers.length === 1 )
      {
        // debugger;
        // op.srcContainerIndex = 0;
        // op.srcContainer = op.dstContainer;
        op.srcElement = fsrc.atomGet( op.key );
        o.onAtom.call( o.dst,op );

        if( o.onContinue )
        if( o.onContinue( o ) === false )
        brk = 1;

      }
      else for( var s = 1 ; s < op.srcContainers.length ; s++ )
      {
        debugger;
        // op.srcContainerIndex = s;
        // op.srcContainer = op.srcContainers[ s ];
        op.srcElement = op.srcContainers[ s ].atomGet( op.key );
        o.onAtom.call( o.dst,op );

        if( o.onContinue )
        if( o.onContinue( o ) === false )
        {
          brk = 1;
          break;
        }

      }

      // if( !o.reducing )
      // debugger;
      if( !o.reducing )
      op.dstContainer.atomSet( op.key,op.dstElement );

      if( o.onAtomsEnd )
      o.onAtomsEnd( op );

      if( brk )
      break;
    }

    if( brk )
    break;
  }

  return o.onVectorsEnd.call( o.dst,op );
}

atomWiseHomogeneous.defaults =
{
  onAtom : null,
  onAtomsBegin : null,
  onAtomsEnd : null,
  onVectorsBegin : null,
  onVectorsEnd : null,
  onContinue : null,
  args : null,
  dst : _.nothing,
  usingDstAsSrc : 0,
  usingExtraSrcs : 0,
  reducing : 0,
}

//

// function atomWiseHomogeneousZip( o )
// {
//   var proto = this;
//   var newDst = false;
//
//   /* preliminary analysis */
//
//   var dims = null;
//   for( var s = 0 ; s < o.srcs.length ; s++ )
//   {
//     var src = o.srcs[ s ];
//     if( src instanceof Self )
//     if( dims )
//     _.assert( _.arrayIdentical( src.dims,dims ) )
//     else
//     dims = src.dims;
//   }
//
//   /* allocation */
//
//   if( o.dst === null )
//   {
//     o.dst = proto.makeZero( dims );
//     newDst = true;
//   }
//
//   for( var s = 0 ; s < o.srcs.length ; s++ )
//   {
//     var src = o.srcs[ s ] = wSpace.from( o.srcs[ s ],dims );
//     _.assert( src instanceof Self );
//   }
//
//   /* verification */
//
//   _.assertMapHasOnly( o,atomWiseHomogeneousZip.defaults );
//   _.assert( o.srcs[ 0 ] instanceof Self );
//   _.assert( !proto.instanceIs() );
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( o.dst.dims.length === 2, 'not implemented' );
//   _.assert( _.arrayIdentical( o.dst.dims,dims ) )
//
//   /* */
//
//   // var op = o.onVectorsBegin();
//   var op = Object.create( null );
//   op.key = -1;
//   op.args = [ o.dst,o.srcs ];
//   op.dstContainer = o.dst;
//   op.dstElement = null;
//   op.srcContainerIndex = -1;
//   op.srcContainer = null;
//   op.srcElement = null;
//   Object.preventExtensions( op );
//
//   if( o.onBegin )
//   o.onBegin.call( o.dst,op );
//
//   /* */
//
//   for( var c = 0 ; c < o.dst.atomsPerCol ; c++ )
//   for( var r = 0 ; r < o.dst.atomsPerRow ; r++ )
//   {
//     op.key = [ c,r ];
//     op.dstElement = o.dst.atomGet( op.key );
//
//     if( o.onAtomsBegin )
//     o.onAtomsBegin( op );
//
//     op.srcContainerIndex = 0;
//     op.srcContainer = o.srcs[ 0 ];
//     op.dstElement = op.srcContainer.atomGet( op.key );
//
//     for( var s = 1 ; s < o.srcs.length ; s++ )
//     {
//       op.srcContainerIndex = s;
//       op.srcContainer = o.srcs[ s ];
//       op.srcElement = op.srcContainer.atomGet( op.key );
//       o.onAtom.call( o.dst,op );
//     }
//
//     if( o.onAtomsEnd )
//     o.onAtomsEnd( op );
//
//   }
//
//   return o.dst;
// }
//
// atomWiseHomogeneousZip.defaults =
// {
//   onAtom : null,
//   onAtomsBegin : null,
//   onAtomsEnd : null,
//   dst : null,
//   srcs : null,
// }

//

function atomWiseZip( onAtom,dst,srcs )
{
  var self = this;
  var result;

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( self.dims.length === 2, 'not implemented' );

  var op = Object.create( null );
  op.key = -1;
  op.args = [ dst,srcs ];
  op.dstContainer = self;
  op.dstElement = null;
  op.srcContainers = srcs;
  op.srcElements = [];
  Object.preventExtensions( op );

  /* */

  for( var s = 0 ; s < srcs.length ; s++ )
  {
    var src = srcs[ s ];
    _.assert( srcs[ s ] instanceof Self );
  }

  /* */

  for( var c = 0 ; c < self.atomsPerCol ; c++ )
  for( var r = 0 ; r < self.atomsPerRow ; r++ )
  {
    op.key = [ c,r ];
    op.dstElement = self.atomGet( op.key );

    for( var s = 0 ; s < srcs.length ; s++ )
    op.srcElements[ s ] = srcs[ s ].atomGet( op.key );

    onAtom.call( self,op );
  }

  return self;
}

//

function elementEach( onElement )
{
  var self = this;
  var args = _.arraySlice( arguments,1 );

  debugger;
  _.assert( 0,'not tested' );

  args.unshift( null );
  args.unshift( null );

  for( var i = 0 ; i < self.length ; i++ )
  {
    args[ 0 ] = self.eGet( i );
    args[ 1 ] = i;
    onElement.apply( self,args );
  }

  return self;
}

//

function elementsZip( onEach,space )
{
  var self = this;
  var args = _.arraySlice( arguments,2 );

  args.unshift( null );
  args.unshift( null );

  throw _.err( 'Not tested' );

  for( var i = 0 ; i < self.length ; i++ )
  {
    args[ 0 ] = self.eGet( i );
    args[ 1 ] = space.eGet( i );
    onEach.apply( self,args );
  }

  return self;
}

//

function _lineEachCollecting( o )
{
  var self = this;
  // var returningRow = o.onEach.returningSelf !== false || o.onEach.returningNew !== false;
  // var returningNumber = o.onEach.returningNumber === true;

  _.assert( self.dims.length === 2 );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayLike( o.args ) );
  _.assert( o.length >= 0 );
  _.assert( _.boolLike( o.returningNumber ) );
  // _.assert( _.boolIs( o.onEach.returningSelf ) && _.boolIs( o.onEach.returningNew ) && _.boolIs( o.onEach.returningNumber ) )

  /* */

  o.args = _.arraySlice( o.args );

  if( !o.args[ 0 ] )
  {
    if( o.returningNumber )
    o.args[ 0 ] = vector.makeArrayOfLength( o.length );
    else
    o.args[ 0 ] = [];
  }

  if( o.returningNumber )
  if( !_.vectorIs( o.args[ 0 ] ) )
  o.args[ 0 ] = vector.fromArray( o.args[ 0 ] );

  var result = o.args[ 0 ];

  /* */

  if( o.returningNumber )
  for( var i = 0 ; i < o.length ; i++ )
  {
    o.args[ 0 ] = self.lineVectorGet( o.lineOrder,i );
    result.eSet( i,o.onEach.apply( self,o.args ) );
  }
  else
  for( var i = 0 ; i < o.length ; i++ )
  {
    o.args[ 0 ] = self.lineVectorGet( o.lineOrder,i );
    result[ i ] = o.onEach.apply( self,o.args );
  }

  /* */

  return result;
}

_lineEachCollecting.defaults =
{
  onEach : null,
  args : null,
  length : null,
  lineOrder : null,
  returningNumber : null,
}

//

function colEachCollecting( onEach , args , returningNumber )
{
  var self = this;

  _.assert( arguments.length === 3, 'expects exactly three argument' );

  var result = self._lineEachCollecting
  ({
    onEach : onEach,
    args : args,
    length : self.atomsPerRow,
    lineOrder : 0,
    returningNumber : returningNumber,
  });

  return result;
}

//

function rowEachCollecting( onEach , args , returningNumber )
{
  var self = this;

  _.assert( arguments.length === 3, 'expects exactly three argument' );

  var result = self._lineEachCollecting
  ({
    onEach : onEach,
    args : args,
    length : self.atomsPerCol,
    lineOrder : 1,
    returningNumber : returningNumber,
  });

  return result;
}

//

// function _reduceToScalar( o )
// {
//   var self = this;
//   var onVector = o.onVector;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.routineOptions( _reduceToScalar,o );
//   _.assert( self.dims === 2,'not implemented' );
//
//   /* */
//
//   debugger;
//   var atomsPerRow = self.atomsPerRow;
//   var rvector = _.vector.zeroes( atomsPerRow );
//   for( var i = 0 ; i < atomsPerCol ; i++ )
//   {
//     debugger;
//     var e = onVector.call( self.colVectorGet( i ) );
//     _.assert( _.numberIs( e ) );
//     rvector.eset( i,e );
//     debugger;
//   }
//
//   debugger;
//   var result = onVector.call( rvector );
//
//   /* */
//
//   debugger;
//   return result;
// }
//
// _lineEachCollecting.defaults =
// {
//   onVector : null,
// }

// --
// components accessor
// --

function atomFlatGet( index )
{
  var i = this.offset+index;
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.numberIs( index ) );
  _.assert( i < this.buffer.length );
  _.assert( this.occupiedRange[ 0 ] <= i && i < this.occupiedRange[ 1 ] );
  var result = this.buffer[ i ];
  return result;
}

//

function atomFlatSet( index,value )
{
  var i = this.offset+index;
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.numberIs( index ) );
  _.assert( i < this.buffer.length );
  _.assert( this.occupiedRange[ 0 ] <= i && i < this.occupiedRange[ 1 ] );
  this.buffer[ i ] = value;
  return this;
}

//

function atomGet( index )
{
  var i = this.flatAtomIndexFrom( index );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( i < this.buffer.length );
  _.assert( this.occupiedRange[ 0 ] <= i && i < this.occupiedRange[ 1 ] );
  _.assert( index[ 0 ] < this.dims[ 0 ] );
  _.assert( index[ 1 ] < this.dims[ 1 ] );
  var result = this.buffer[ i ];
  return result;
}

//

function atomSet( index,value )
{
  var i = this.flatAtomIndexFrom( index );
  _.assert( _.numberIs( value ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( i < this.buffer.length );
  _.assert( this.occupiedRange[ 0 ] <= i && i < this.occupiedRange[ 1 ] );
  _.assert( index[ 0 ] < this.dims[ 0 ] );
  _.assert( index[ 1 ] < this.dims[ 1 ] );
  this.buffer[ i ] = value;
  return this;
}

//

function atomsGet( range )
{
  var self = this;

  _.assert( _.arrayLike( range ) );
  _.assert( range.length === 2 );
  _.assert( self.breadth.length === 1 );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( range[ 1 ] >= range[ 0 ] );

  debugger;

  var result = vector.fromSubArray
  (
    self.buffer,
    self.offset+range[ 0 ],
    ( range[ 1 ]-range[ 0 ] )
  );

  debugger;

  return result;
}

//

function asVector()
{
  var self = this
  var result = null;

  _.assert( arguments.length === 0 );
  _.assert( self.strideOfElement === self.atomsPerElement );
  _.assert( self.strideOfElement === self.atomsPerElement,'elementsInRangeGet :','cant make single row for elements with extra stride' );

  result = vector.fromSubArray
  (
    self.buffer,
    self.occupiedRange[ 0 ],
    self.occupiedRange[ 1 ]-self.occupiedRange[ 0 ]
  );

  return result;
}

//

function granuleGet( index )
{
  var self = this;
  var atomsPerGranule;

  debugger;
  _.assert( 0,'not imlemented' );

  if( index.length < self._stridesEffective.length+1 )
  atomsPerGranule = _.avector.reduceToProduct( self._stridesEffective.slice( index.length-1 ) );
  else
  atomsPerGranule = 1;

  var result = vector.fromSubArray
  (
    this.buffer,
    this.offset + this.flatGranuleIndexFrom( index ),
    atomsPerGranule
  );

  return result;
}

//

function elementSlice( index )
{
  var self = this;
  var result = self.eGet( index );
  return _.vector.slice( result );
}

//

function elementsInRangeGet( range )
{
  var self = this
  var result;

  _.assert( _.arrayLike( range ) );
  _.assert( range.length === 2 );
  _.assert( self.breadth.length === 1 );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( range[ 1 ] >= range[ 0 ] );

  _.assert( self.strideOfElement === self.atomsPerElement,'elementsInRangeGet :','cant make single row for elements with extra stride' );
  // _.assert( self.strideOfElement === self.atomsPerElement || self.strideOfElement === 0 );

  debugger;

  if( self.strideOfElement !== self.atomsPerElement )
  debugger;

  // if( self.strideOfElement === 0 )
  // result = vector.fromSubArrayWithStride
  // (
  //   self.buffer,
  //   self.offset+self.strideOfElement*range[ 0 ],
  //   self.atomsPerElement*( range[ 1 ]-range[ 0 ] ),
  //   0
  // );
  // else
  result = vector.fromSubArray
  (
    self.buffer,
    self.offset+self.strideOfElement*range[ 0 ],
    self.atomsPerElement*( range[ 1 ]-range[ 0 ] )
  );

  return result;
}

//

function eGet( index )
{

  _.assert( this.dims.length === 2,'not implemented' );
  _.assert( 0 <= index && index < this.dims[ this.dims.length-1 ],'out of bound' );
  _.assert( _.numberIs( index ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  var result = vector.fromSubArrayWithStride
  (
    this.buffer,
    this.offset + index*this._stridesEffective[ this._stridesEffective.length-1 ],
    this.dims[ this.dims.length-2 ],
    this._stridesEffective[ this._stridesEffective.length-2 ]
  );

  return result;
}

//

function eSet( index,srcElement )
{
  var self = this;
  var selfElement = self.eGet( index );

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  vector.assign( selfElement,srcElement );

  return self;
}

//

function elementsSwap( i1,i2 )
{
  var self = this;

  _.assert( 0 <= i1 && i1 < self.length );
  _.assert( 0 <= i2 && i2 < self.length );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( i1 === i2 )
  return self;

  var v1 = self.eGet( i1 );
  var v2 = self.eGet( i2 );

  vector.swapVectors( v1,v2 );

  return self;
}

//

function lineVectorGet( d,index )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( self.dims.length === 2 );

  if( d === 0 )
  return self.colVectorGet( index );
  else if( d === 1 )
  return self.rowVectorGet( index );
  else
  _.assert( 0,'unknown dimension' );

}

//

function lineSet( d,index,src )
{
  var self = this;

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( self.dims.length === 2 );

  if( d === 0 )
  return self.colSet( index,src );
  else if( d === 1 )
  return self.rowSet( index,src );
  else
  _.assert( 0,'unknown dimension' );

}

//

function linesSwap( d,i1,i2 )
{
  var self = this;

  var ad = d+1;
  if( ad > 1 )
  ad = 0;

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( self.dims.length === 2 );
  _.assert( 0 <= i1 && i1 < self.dims[ d ] );
  _.assert( 0 <= i2 && i2 < self.dims[ d ] );

  if( i1 === i2 )
  return self;

  var v1 = self.lineVectorGet( ad,i1 );
  var v2 = self.lineVectorGet( ad,i2 );

  vector.swapVectors( v1,v2 );

  return self;
}

//

function rowVectorOfMatrixGet( matrixIndex,rowIndex )
{

  debugger;
  throw _.err( 'not tested' );
  _.assert( index < this.dims[ 1 ] );

  var matrixOffset = this.flatGranuleIndexFrom( matrixIndex );
  var result = vector.fromSubArrayWithStride
  (
    this.buffer,
    this.offset + rowIndex*this.strideOfRow + matrixOffset,
    this.atomsPerRow,
    this.strideInRow
  );

  // var result = vector.fromSubArrayWithStride
  // (
  //   this.buffer,
  //   this.offset + rowIndex*this._stridesEffective[ 0 ] + matrixOffset,
  //   this.dims[ 1 ],
  //   this._stridesEffective[ 1 ]
  // );

  return result;
}

//

function rowVectorGet( index )
{

  _.assert( this.dims.length === 2,'not implemented' );
  _.assert( 0 <= index && index < this.dims[ 0 ],'out of bound' );
  _.assert( _.numberIs( index ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  var result = vector.fromSubArrayWithStride
  (
    this.buffer,
    this.offset + index*this.strideOfRow,
    this.atomsPerRow,
    this.strideInRow
  );

  return result;
}

//

function rowSet( rowIndex,srcRow )
{
  var self = this;
  var selfRow = self.rowVectorGet( rowIndex );

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  vector.assign( selfRow,srcRow );

  return self;
}

//

function rowsSwap( i1,i2 )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  return self.linesSwap( 0,i1,i2 );
}

//

function colVectorGet( index )
{

  _.assert( this.dims.length === 2,'not implemented' );
  _.assert( 0 <= index && index < this.dims[ 1 ],'out of bound' );
  _.assert( _.numberIs( index ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  var result = vector.fromSubArrayWithStride
  (
    this.buffer,
    this.offset + index*this.strideOfCol,
    this.atomsPerCol,
    this.strideInCol
  );

  return result;
}

//

function colSet( index,srcCol )
{
  var self = this;
  var selfCol = self.colVectorGet( index );

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  vector.assign( selfCol,srcCol );

  return self;
}

//

function colsSwap( i1,i2 )
{
  var self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  return self.linesSwap( 1,i1,i2 );
}

//

function _pivotDimension( d,current,expected )
{
  var self = this;

  for( var p1 = 0 ; p1 < expected.length ; p1++ )
  {
    if( expected[ p1 ] === current[ p1 ] )
    continue;
    var p2 = current[ expected[ p1 ] ];
    _.arraySwap( current,p2,p1 );
    self.linesSwap( d,p2,p1 );
  }

  _.assert( expected.length === self.dims[ d ] );
  _.assert( _.arrayIdentical( current,expected ) );

}

//

function pivotForward( pivots )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( pivots.length === self.dims.length );

  for( var d = 0 ; d < pivots.length ; d++ )
  {
    var current = _.arrayFromRange([ 0,self.dims[ d ] ]);
    var expected = pivots[ d ];
    if( expected === null )
    continue;
    self._pivotDimension( d,current,expected )
  }

  return self;
}

//

function pivotBackward( pivots )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( pivots.length === self.dims.length );

  for( var d = 0 ; d < pivots.length ; d++ )
  {
    var current = pivots[ d ];
    var expected = _.arrayFromRange([ 0,self.dims[ d ] ]);
    if( current === null )
    continue;
    current = current.slice();
    self._pivotDimension( d,current,expected )
  }

  return self;
}

//

function _vectorPivotDimension( v,current,expected )
{
  var self = this;

  for( var p1 = 0 ; p1 < expected.length ; p1++ )
  {
    if( expected[ p1 ] === current[ p1 ] )
    continue;
    var p2 = current[ expected[ p1 ] ];
    _.arraySwap( current, p1, p2 );
    vector.swapAtoms( v, p1, p2 );
  }

  _.assert( expected.length === v.length );
  _.assert( _.arrayIdentical( current,expected ) );

}

//

function vectorPivotForward( vector,pivot )
{
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.arrayIs( pivot ) );

  if( _.spaceIs( vector ) )
  return vector.pivotForward([ pivot,null ]);

  var original = vector;
  var vector = _.vector.from( vector );
  var current = _.arrayFromRange([ 0,vector.length ]);
  var expected = pivot;
  if( expected === null )
  return vector;
  this._vectorPivotDimension( vector,current,expected )

  return original;
}

//

function vectorPivotBackward( vector,pivot )
{
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.arrayIs( pivot ) );

  if( _.spaceIs( vector ) )
  return vector.pivotBackward([ pivot,null ]);

  var original = vector;
  var vector = _.vector.from( vector );
  var current = pivot.slice();
  var expected = _.arrayFromRange([ 0,vector.length ]);
  if( current === null )
  return vector;
  this._vectorPivotDimension( vector,current,expected )

  return original;
}

// --
// relationships
// --

var offsetSymbol = Symbol.for( 'offset' );
var bufferSymbol = Symbol.for( 'buffer' );
var breadthSymbol = Symbol.for( 'breadth' );
var dimsSymbol = Symbol.for( 'dims' );

var stridesSymbol = Symbol.for( 'strides' );
var lengthSymbol = Symbol.for( 'length' );
var stridesEffectiveSymbol = Symbol.for( '_stridesEffective' );

var atomsPerElementSymbol = Symbol.for( 'atomsPerElement' );
var occupiedRangeSymbol = Symbol.for( 'occupiedRange' );

//

var Composes =
{

  dims : null,
  growingDimension : 1,
  inputTransposing : null,

  // strides : null,

}

//

var Aggregates =
{
  buffer : null,
}

//

var Associates =
{
}

//

var Restricts =
{

  _dimsWas : null,
  _changing : [ 1 ],

  // buffer : null,

  // strides : null,
  // offset : 0,
  // breadth : null,

}

//

var Medials =
{

  // buffer : null,
  strides : null,
  offset : 0,
  breadth : null,

}

//

var Statics =
{

  /* */

  copyTo : copyTo,

  atomsPerSpaceForDimensions : atomsPerSpaceForDimensions,
  nrowOf : nrowOf,
  ncolOf : ncolOf,
  dimsOf : dimsOf,
  shapesAreSame : shapesAreSame,

  stridesForDimensions : stridesForDimensions,
  stridesRoll : stridesRoll,

  _flatAtomIndexFromIndexNd : _flatAtomIndexFromIndexNd,

  _bufferFrom : _bufferFrom,
  is : is,


  /* iterator */

  atomWiseHomogeneous : atomWiseHomogeneous,
  // atomWiseHomogeneousZip : atomWiseHomogeneousZip,
  atomWiseZip : atomWiseZip,


  /* pivot */

  _vectorPivotDimension : _vectorPivotDimension,
  vectorPivotForward : vectorPivotForward,
  vectorPivotBackward : vectorPivotBackward,


  /* var */

  array : _.ArrayNameSpaces.Float32,
  withArray : _.ArrayNameSpaces,
  accuracy : accuracy,
  accuracySqr : accuracySqr,

}

//

var Forbids =
{

  stride : 'stride',

  strideInBytes : 'strideInBytes',
  strideInAtoms : 'strideInAtoms',

  stridePerElement : 'stridePerElement',
  lengthInStrides : 'lengthInStrides',

  dimensions : 'dimensions',
  dimensionsWithLength : 'dimensionsWithLength',
  stridesEffective : 'stridesEffective',

  colLength : 'colLength',
  rowLength : 'rowLength',

  _generator : '_generator',
  usingOptimizedAccessors : 'usingOptimizedAccessors',
  dimensionsDesired : 'dimensionsDesired',

}

//

var ReadOnlyAccessors =
{

  /* size in bytes */

  size : 'size',
  sizeOfElement : 'sizeOfElement',
  sizeOfElementStride : 'sizeOfElementStride',
  sizeOfCol : 'sizeOfCol',
  sizeOfColStride : 'sizeOfColStride',
  sizeOfRow : 'sizeOfRow',
  sizeOfRowStride : 'sizeOfRowStride',
  sizeOfAtom : 'sizeOfAtom',

  /* size in atoms */

  atomsPerElement : 'atomsPerElement', /*  cached*/
  atomsPerCol : 'atomsPerCol',
  atomsPerRow : 'atomsPerRow',
  ncol : 'ncol',
  nrow : 'nrow',
  atomsPerSpace : 'atomsPerSpace',

  /* length */

  length : 'length', /* cached */
  occupiedRange : 'occupiedRange', /* cached */
  _stridesEffective : '_stridesEffective', /* cached */

  strideOfElement : 'strideOfElement',
  strideOfCol : 'strideOfCol',
  strideInCol : 'strideInCol',
  strideOfRow : 'strideOfRow',
  strideInRow : 'strideInRow',

}

//

var Accessors =
{

  buffer : 'buffer',
  offset : 'offset',

  strides : 'strides',
  dims : 'dims',
  breadth : 'breadth',

}

// --
// define class
// --

var Proto =
{

  init : init,

  _traverseAct : _traverseAct,
  _copy : _copy,
  copy : copy,
  copyResetting : copyResetting,

  copyFromScalar : copyFromScalar,
  copyFromBuffer : copyFromBuffer,
  clone : clone,

  copyTo : copyTo,

  extractNormalized : extractNormalized,


  /* size in bytes */

  '_sizeGet' : _sizeGet,

  '_sizeOfElementGet' : _sizeOfElementGet,
  '_sizeOfElementStrideGet' : _sizeOfElementStrideGet,

  '_sizeOfColGet' : _sizeOfColGet,
  '_sizeOfColStrideGet' : _sizeOfColStrideGet,

  '_sizeOfRowGet' : _sizeOfRowGet,
  '_sizeOfRowStrideGet' : _sizeOfRowStrideGet,

  '_sizeOfAtomGet' : _sizeOfAtomGet,


  /* size in atoms */

  '_atomsPerElementGet' : _atomsPerElementGet, /* cached */
  '_atomsPerColGet' : _atomsPerColGet,
  '_atomsPerRowGet' : _atomsPerRowGet,
  '_nrowGet' : _nrowGet,
  '_ncolGet' : _ncolGet,
  '_atomsPerSpaceGet' : _atomsPerSpaceGet,

  atomsPerSpaceForDimensions : atomsPerSpaceForDimensions,
  nrowOf : nrowOf,
  ncolOf : ncolOf,


  /* stride */

  '_lengthGet' : _lengthGet, /* cached */
  '_occupiedRangeGet' : _occupiedRangeGet, /* cached */

  '_stridesEffectiveGet' : _stridesEffectiveGet, /* cached */
  '_stridesSet' : _stridesSet, /* cached */

  '_strideOfElementGet' : _strideOfElementGet,
  '_strideOfColGet' : _strideOfColGet,
  '_strideInColGet' : _strideInColGet,
  '_strideOfRowGet' : _strideOfRowGet,
  '_strideInRowGet' : _strideInRowGet,

  stridesForDimensions : stridesForDimensions,
  stridesRoll : stridesRoll,


  /* buffer */

  '_bufferSet' : _bufferSet, /* cached */
  '_offsetSet' : _offsetSet, /* cached */

  _bufferCopy : _bufferCopy,
  bufferCopyTo : bufferCopyTo,


  /* reshape */

  _changeBegin : _changeBegin,
  _changeEnd : _changeEnd,

  _sizeChanged : _sizeChanged,

  _adjust : _adjust,
  _adjustAct : _adjustAct,
  _adjustVerify : _adjustVerify,
  _adjustValidate : _adjustValidate,

  '_breadthGet' : _breadthGet, /* cached */
  '_breadthSet' : _breadthSet,
  '_dimsSet' : _dimsSet, /* cached */

  expand : expand,

  shapesAreSame : shapesAreSame,
  hasShape : hasShape,
  isSquare : isSquare,


  /* etc */

  flatAtomIndexFrom : flatAtomIndexFrom,
  _flatAtomIndexFromIndexNd : _flatAtomIndexFromIndexNd,
  flatGranuleIndexFrom : flatGranuleIndexFrom,

  transpose : transpose,

  _equalAre : _equalAre,
  equalWith : equalWith,

  is : is,
  toStr : toStr,
  _bufferFrom : _bufferFrom,

  bufferNormalize : bufferNormalize,
  subspace : subspace,


  /* iterator */

  atomWhile : atomWhile,
  atomEach : atomEach,
  atomWiseReduceWithFlatVector : atomWiseReduceWithFlatVector,
  atomWiseReduceWithAtomHandler : atomWiseReduceWithAtomHandler,
  atomWiseWithAssign : atomWiseWithAssign,
  atomWiseHomogeneous : atomWiseHomogeneous,
  // atomWiseHomogeneousZip : atomWiseHomogeneousZip,
  atomWiseZip : atomWiseZip,

  elementEach : elementEach,
  elementsZip : elementsZip,

  _lineEachCollecting : _lineEachCollecting,
  rowEachCollecting : rowEachCollecting,
  colEachCollecting : colEachCollecting,


  /*

  iterators :

  - map
  - filter
  - reduce
  - zip

  */

  /* components accessor */

  atomFlatGet : atomFlatGet,
  atomFlatSet : atomFlatSet,
  atomGet : atomGet,
  atomSet : atomSet,
  atomsGet : atomsGet,
  asVector : asVector,

  granuleGet : granuleGet,
  elementSlice : elementSlice,
  elementsInRangeGet : elementsInRangeGet,
  eGet : eGet,
  eSet : eSet,
  elementsSwap : elementsSwap,

  lineVectorGet : lineVectorGet,
  lineSet : lineSet,
  linesSwap : linesSwap,

  rowVectorOfMatrixGet : rowVectorOfMatrixGet,
  rowVectorGet : rowVectorGet,
  rowSet : rowSet,
  rowsSwap : rowsSwap,

  colVectorGet : colVectorGet,
  colSet : colSet,
  colsSwap : colsSwap,

  _pivotDimension : _pivotDimension,
  pivotForward : pivotForward,
  pivotBackward : pivotBackward,

  _vectorPivotDimension : _vectorPivotDimension,
  vectorPivotForward : vectorPivotForward,
  vectorPivotBackward : vectorPivotBackward,


  /* relationships */

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Medials : Medials,
  Statics : Statics,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

_.assert( Self.prototype.array );
_.assert( Self.prototype.withArray );
_.assert( _.withArray );
_.assert( _.withArray.Float32 );
_.assert( _.ArrayNameSpaces.Float32 );
_.assert( _.ArrayNameSpaces.Float32.makeArrayOfLength );

//

_.accessorForbid( Self.prototype,Forbids );
_.accessorReadOnly( Self.prototype,ReadOnlyAccessors );
_.accessor( Self.prototype,Accessors );

//

_.mapExtendConditional( _.field.mapper.srcOwnPrimitive, Self, Composes );
_global_.wSpace = _.Space = Self;

//

if( typeof module !== 'undefined' )
{
  require( './wSpaceMethods.s' );
  require( './wSpaceVector.s' );
}

})();
