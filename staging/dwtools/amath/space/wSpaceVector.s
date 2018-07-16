(function _wSpaceVector_s_() {

'use strict'; /**/

//

var _ = _global_.wTools;
var vector = _.vector;
var operations = vector.operations;

var _abs = Math.abs;
var _min = Math.min;
var _max = Math.max;
var _arraySlice = Array.prototype.slice;
var _sqrt = Math.sqrt;
var _sqr = _.sqr;

var Parent = null;
var Self = _global_.wSpace;
var Proto = Object.create( null );
var Statics = Proto.Statics = Object.create( null );

_.assert( _.routineIs( Self ),'wSpace is not defined, please include wSpace.s first' );

/*
map
filter
reduce
zip
*/

//

function declareElementsZipRoutine( routine,rname )
{

  if( routine.operation.takingVectors[ 1 ] < 2 )
  return;

  if( routine.operation.takingArguments[ 0 ] > routine.operation.takingVectors[ 0 ] )
  return;

  if( routine.operation.takingArguments[ 0 ] === 1 )
  return;

  // if( rname === 'allFinite' )
  // debugger;

  var name = rname + 'Zip';
  Proto[ name ] = function()
  {
    var self = this;
    var args = _.arraySlice( arguments );
    args.unshift( routine );

    debugger;
    throw _.err( 'Not tested' );

    self.elementsZip.apply( self,args ); xxx

    return self;
  }

}

//

function declareColWiseCollectingRoutine( routine,rname )
{

  var op = routine.operation;
  var returningNumber = op.returningNumber;
  var name = r + 'ColWise';

  _.assert( _.boolIs( returningNumber ) );
  _.assert( !Proto[ name ] );

  Proto[ name ] = function reduceColWise()
  {
    var self = this;

    var result = self.colEachCollecting( routine , arguments , returningNumber );

    return result;
  }

}

//

function declareRowWiseCollectingRoutine( routine , rname )
{

  var op = routine.operation;
  var returningNumber = op.returningNumber;
  var name = rname + 'RowWise';

  _.assert( _.boolIs( returningNumber ) );
  _.assert( !Proto[ name ] );

  Proto[ name ] = function reduceRowWise()
  {
    var self = this;

    var result = self.rowEachCollecting( routine , arguments , returningNumber );

    return result;
  }

}

//

function declareAtomWiseReducingRoutine( routine , rname )
{
  var op = routine.operation;

  _.assert( arguments.length === 2 )

  // if( rname === 'allFinite' )
  // debugger;

  if( !op.reducing )
  return;

  // if( !op.takingVectorsOnly )
  // return;

  if( op.conditional )
  return;

  if( !op.reducing )
  return;

  if( !op.onAtom )
  return;

  // if( op.kind !== 'atomWiseReducing' )
  // return;

  if( op.generator.name !== '__operationReduceToScalar_functor' )
  return;

  if( _.arrayIdentical( op.takingArguments,[ 1,1 ] ) )
  return;

  // debugger;

  var name = rname + 'AtomWise';
  var handleAtom = op.onAtom[ 0 ];
  var onAtomsBegin0 = op.onAtomsBegin[ 0 ];
  var onAtomsEnd0 = op.onAtomsEnd[ 0 ];
  var onVectorsBegin0 = op.onVectorsBegin[ 0 ];
  var onVectorsEnd0 = op.onVectorsEnd[ 0 ];

  function onBegin( o )
  {
    var op = onVectorsBegin0( o );
    onAtomsBegin0( op );
    return op;
  }

  function onEnd( op )
  {
    onAtomsEnd0( op );
    var result = onVectorsEnd0( op );
    return result;
  }

  _.assert( handleAtom.defaults );
  _.assert( onAtomsBegin0 );
  _.assert( onAtomsEnd0 );
  _.assert( onVectorsBegin0 );
  _.assert( onVectorsEnd0 );
  _.assert( !Proto[ name ] );

  Proto[ name ] = function atomWise()
  {
    var self = this;

    _.assert( arguments.length === 0 );

    var result = self.atomWiseReduceWithAtomHandler( onBegin,handleAtom,onEnd );

    return result;
  }

}

//

function declareAtomWiseHomogeneousWithScalarRoutines( routine,rname )
{
  var op = routine.operation;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( op.reducing )
  return;
  if( !op.homogeneous )
  return;
  if( op.special )
  return;

  if( op.takingArguments[ 0 ] !== 2 || op.takingArguments[ 1 ] !== 2 )
  return;

  var onAtom = op.onAtom[ 1 ];
  var name = rname;

  _.assert( !Proto[ name ] );
  _.assert( op );
  _.assert( _.routineIs( onAtom ) );

  /* */

  function handleAtom2( op )
  {
    var self = this;

    debugger;
    op.srcElement = op.args[ 0 ];
    var val = onAtom( op );
    _.assert( val === undefined );
    _.assert( _.numberIs( op.dstElement ) );
    _.assert( _.numberIs( op.srcElement ) );
    self.atomSet( op.key,op.dstElement );

  }

  handleAtom2.have = { onAtom : onAtom };

  /* */

  Proto[ name ] = function atomWise()
  {
    var self = this;

    _.assert( arguments.length === 1, 'expects single argument' );
    _.assert( _.numberIs( arguments[ 0 ] ) );

    self.atomWiseWithAssign( handleAtom2,arguments );

    return self;
  }

}

//

function declareAtomWiseHomogeneousRoutine( routine,name )
{
  var dop = routine.operation;

  if( !dop.atomWise )
  return;

  if( !dop.homogeneous )
  return;

  if( !dop.input )
  return;

  if( dop.kind === 'reducing' )
  return;

  if( _.arrayIdentical( dop.input,[ 'vw|s', 's' ] ) )
  return;

  var routineName = name + 'AtomWise';
  var onAtom0 = dop.onAtom[ 0 ];
  var onAtom1 = dop.onAtom[ 1 ];
  var onVectorsBegin0 = dop.onVectorsBegin[ 0 ];
  var onVectorsEnd0 = dop.onVectorsEnd[ 0 ];
  var onContinue0 = dop.onContinue[ 0 ];

  _.assert( _.routineIs( onAtom0 ) );
  _.assert( _.routineIs( onAtom1 ) );
  _.assert( onAtom0.defaults );
  _.assert( !onAtom1.defaults );
  _.assert( !Statics[ routineName ] );
  _.assert( !Proto[ routineName ] );

  function onVectorsBegin( o )
  {
    var op = onVectorsBegin0( o );
    return op;
  }

  function handleAtom( o )
  {
    var r = onAtom1.call( this,o );
    _.assert( r === undefined );
  }

  function onVectorsEnd( o )
  {
    o.result = o.dstContainer;
    if( onVectorsEnd0 )
    onVectorsEnd0( o );
    return o.result;
  }

  handleAtom.defaults = onAtom0.defaults;

  /* */

  if( dop.takingArguments[ 0 ] === 1 )
  Proto[ routineName ] = Statics[ routineName ] = function AtomWiseHomogeneous()
  {
    var self = this;
    var dst,args;

    if( _.instanceIs( this ) )
    {
      dst = this;
      args = _.arraySlice( arguments,0 );
      args.unshift( dst );
    }
    else
    {
      dst = arguments[ 0 ];
      args = _.arraySlice( arguments,0 );
    }

    var result = self.Self.atomWiseHomogeneous
    ({
      onContinue : onContinue0,
      onVectorsBegin : onVectorsBegin,
      onVectorsEnd : onVectorsEnd,
      onAtom : handleAtom,
      args : args,
      reducing : dop.reducing,
      usingDstAsSrc : dop.usingDstAsSrc,
      usingExtraSrcs : dop.usingExtraSrcs,
    });

    return result;
  }
  else if( dop.takingArguments[ 0 ] > 1 )
  Statics[ routineName ] = Statics[ routineName ] = function AtomWiseHomogeneous()
  {
    var self = this;
    var dst,args;

    if( _.instanceIs( this ) )
    {
      dst = this;
      args = _.arraySlice( arguments,0 );
      args.unshift( dst );
    }
    else
    {
      dst = arguments[ 0 ];
      args = _.arraySlice( arguments,0 );
    }

    var result = self.Self.atomWiseHomogeneous
    ({
      onVectorsBegin : onVectorsBegin,
      onVectorsEnd : onVectorsEnd,
      onAtom : handleAtom,
      args : args,
      reducing : dop.reducing,
      usingDstAsSrc : dop.usingDstAsSrc,
      usingExtraSrcs : dop.usingExtraSrcs,
    });

    // _.assert( arguments.length === 2, 'expects exactly two arguments' );
    // _.assert( _.arrayIs( srcs ) );
    // var result = self.Self.atomWiseHomogeneousZip
    // ({
    //   onAtomsBegin : onVectorsBegin,
    //   onAtomsEnd : onVectorsEnd,
    //   onAtom : handleAtom,
    //   dst : dst,
    //   srcs : srcs,
    // });

    return result;
  }
  else _.assert( 0 );

}

// //
//
// function declareAtomWiseHomogeneousRoutines()
// {
//
//   for( var op in operations.atomWiseHomogeneous )
//   declareAtomWiseHomogeneousRoutine( operations.atomWiseHomogeneous[ op ],op );
//
//   _.assert( Statics.addAtomWise );
//   _.assert( Statics.allFiniteAtomWise );
//
// }

// --
// aliases
// --

var Aliases =
{
  allFiniteAtomWise : 'allFinite',
  anyNanAtomWise : 'anyNan',
  allIntAtomWise : 'allInt',
  allZeroAtomWise : 'allZero',
}

function declareAliases()
{

  for( var name1 in Aliases )
  {
    var name2 = Aliases[ name1 ];
    _.assert( Proto[ name1 ] );
    _.assert( !Proto[ name2 ] );
    Proto[ name2 ] = Proto[ name1 ];
  }

}

// --
//
// --

var routines = _.vector.RoutinesMathematical;
for( var r in routines )
{
  var routine = routines[ r ];

  _.assert( _.routineIs( routine ) );

  // if( r === 'allIdentical' )
  // debugger;

  declareElementsZipRoutine( routine, r );
  declareColWiseCollectingRoutine( routine, r );
  declareRowWiseCollectingRoutine( routine, r );
  declareAtomWiseReducingRoutine( routine, r );
  declareAtomWiseHomogeneousWithScalarRoutines( routine, r );
  declareAtomWiseHomogeneousRoutine( routine, r );

}

// declareAtomWiseHomogeneousRoutines();

declareAliases();

_.classExtend( Self,Proto );

_.assert( Statics.addAtomWise );
_.assert( Self.prototype.allFiniteAtomWise );

_.assert( Self.prototype.reduceToMaxValueColWise );
_.assert( Self.prototype.reduceToMaxValueRowWise );
_.assert( Self.prototype.addAtomWise );
_.assert( Self.prototype.addScalar );
_.assert( Self.addAtomWise );

_.assert( !Self.prototype.isValidZip );
_.assert( !Self.prototype.anyNanZip );
_.assert( !Self.prototype.allFiniteZip );

_.assert( !Self.prototype.isValidAtomWise );
_.assert( Self.prototype.anyNanAtomWise );
_.assert( Self.prototype.allFiniteAtomWise );

_.assert( !Self.prototype.isValid );
_.assert( Self.prototype.anyNan );
_.assert( Self.prototype.allFinite );

})();
