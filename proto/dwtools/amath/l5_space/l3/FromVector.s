(function _RoutinesFromVector_s_() {

'use strict';

//

let _ = _global_.wTools;
let vector = _.vectorAdapter;
let operations = vector.operations;

let _abs = Math.abs;
let _min = Math.min;
let _max = Math.max;
let _arraySlice = Array.prototype.slice;
let _sqrt = Math.sqrt;
let _sqr = _.sqr;

let Parent = null;
let Self = _global_.wMatrix;
let Proto = Object.create( null );
let Statics = Proto.Statics = Object.create( null );

_.assert( _.routineIs( Self ), 'wMatrix is not defined, please include wMatrix.s first' );

/*
map
filter
reduce
zip
*/

//

function declareElementsZipRoutine( routine, rname )
{

  if( routine.operation.takingVectors[ 1 ] < 2 )
  return;

  if( routine.operation.takingArguments[ 0 ] > routine.operation.takingVectors[ 0 ] )
  return;

  if( routine.operation.takingArguments[ 0 ] === 1 )
  return;

  // if( rname === 'allFinite' )
  // debugger;

  let name = rname + 'Zip';
  Proto[ name ] = function()
  {
    let self = this;

    _.assert( _.objectIs( self.vectorAdapter ) );
    let routine2 = _.routineJoin( self.vectorAdapter, routine );

    let args = _.longSlice( arguments );
    args.unshift( routine2 );

    debugger;
    throw _.err( 'Not tested' );

    self.elementsZip.apply( self, args ); xxx

    return self;
  }

}

//

function declareColWiseCollectingRoutine( routine, rname )
{

  let op = routine.operation;
  let returningNumber = op.returningNumber;
  let name = r + 'ColWise';

  _.assert( _.boolIs( returningNumber ) );
  _.assert( !Proto[ name ] );

  if( name === 'distributionRangeSummary' )
  debugger;

  Proto[ name ] = function reduceColWise()
  {
    let self = this;

    _.assert( _.objectIs( self.vectorAdapter ) );
    let routine2 = _.routineJoin( self.vectorAdapter, routine );
    let result = self.colEachCollecting( routine2 , arguments , returningNumber );

    return result;
  }

}

//

function declareRowWiseCollectingRoutine( routine , rname )
{

  let op = routine.operation;
  let returningNumber = op.returningNumber;
  let name = rname + 'RowWise';

  _.assert( _.boolIs( returningNumber ) );
  _.assert( !Proto[ name ] );

  Proto[ name ] = function reduceRowWise()
  {
    let self = this;

    // let result = self.rowEachCollecting( routine , arguments , returningNumber );

    _.assert( _.objectIs( self.vectorAdapter ) );
    let routine2 = _.routineJoin( self.vectorAdapter, routine );
    let result = self.rowEachCollecting( routine2 , arguments , returningNumber );

    return result;
  }

}

//

function declareAtomWiseReducingRoutine( routine , rname )
{
  let op = routine.operation;

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

  if( op.generator.name !== '__operationReduceToScalar_functor' ) /* xxx */
  return;

  if( _.longIdentical( op.takingArguments, [ 1, 1 ] ) )
  return;

  // debugger;

  let name = rname + 'AtomWise';
  let handleAtom = op.onAtom[ 0 ];
  let onAtomsBegin0 = op.onAtomsBegin[ 0 ];
  let onAtomsEnd0 = op.onAtomsEnd[ 0 ];
  let onVectorsBegin0 = op.onVectorsBegin[ 0 ];
  let onVectorsEnd0 = op.onVectorsEnd[ 0 ];

  function onBegin( o )
  {
    let op = onVectorsBegin0( o );
    onAtomsBegin0( op );
    return op;
  }

  function onEnd( op )
  {
    onAtomsEnd0( op );
    let result = onVectorsEnd0( op );
    return result;
  }

  _.assert( _.objectIs( handleAtom.defaults ) );
  _.assert( _.routineIs( onAtomsBegin0 ) );
  _.assert( _.routineIs( onAtomsEnd0 ) );
  _.assert( _.routineIs( onVectorsBegin0 ) );
  _.assert( _.routineIs( onVectorsEnd0 ) );
  _.assert( !Proto[ name ] );

  Proto[ name ] = function atomWise()
  {
    let self = this;
    _.assert( arguments.length === 0, 'Expects no arguments' );
    let result = self.atomWiseReduceWithAtomHandler( onBegin, handleAtom, onEnd );
    return result;
  }

}

//

function declareAtomWiseHomogeneousWithScalarRoutines( routine, rname )
{
  let op = routine.operation;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( op.reducing )
  return;
  if( !op.homogeneous )
  return;
  if( op.special )
  return;

  if( op.takingArguments[ 0 ] !== 2 || op.takingArguments[ 1 ] !== 2 )
  return;

  let onAtom = op.onAtom[ 1 ];
  let name = rname;

  _.assert( !Proto[ name ] );
  _.assert( _.objectIs( op ) );
  _.assert( _.routineIs( onAtom ) );

  /* */

  function handleAtom2( op )
  {
    let self = this;

    op.srcElement = op.args[ 0 ];
    let val = onAtom( op );
    _.assert( val === undefined );
    _.assert( _.numberIs( op.dstElement ) );
    _.assert( _.numberIs( op.srcElement ) );
    self.atomSet( op.key, op.dstElement );

  }

  handleAtom2.have = { onAtom };

  /* */

  Proto[ name ] = function atomWise()
  {
    let self = this;

    _.assert( arguments.length === 1, 'Expects single argument' );
    _.assert( _.numberIs( arguments[ 0 ] ) );

    self.atomWiseWithAssign( handleAtom2, arguments );

    return self;
  }

}

//

function declareAtomWiseHomogeneousRoutine( routine, name )
{
  let dop = routine.operation;

  if( !dop.atomWise )
  return;

  if( !dop.homogeneous )
  return;

  if( !dop.input )
  return;

  if( dop.kind === 'reducing' )
  return;

  if( _.longIdentical( dop.input, [ 'vw|s', 's' ] ) )
  return;

  let routineName = name + 'AtomWise';
  let onAtom0 = dop.onAtom[ 0 ];
  let onAtom1 = dop.onAtom[ 1 ];
  let onVectorsBegin0 = dop.onVectorsBegin[ 0 ];
  let onVectorsEnd0 = dop.onVectorsEnd[ 0 ];
  let onContinue0 = dop.onContinue[ 0 ];

  _.assert( _.routineIs( onAtom0 ) );
  _.assert( _.routineIs( onAtom1 ) );
  _.assert( _.objectIs( onAtom0.defaults ) );
  _.assert( !onAtom1.defaults );
  _.assert( !Statics[ routineName ] );
  _.assert( !Proto[ routineName ] );

  function onVectorsBegin( o )
  {
    let op = onVectorsBegin0( o );
    return op;
  }

  function handleAtom( o )
  {
    let r = onAtom1.call( this, o );
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
    let self = this;
    let dst, args;

    if( _.instanceIs( this ) )
    {
      dst = this;
      args = _.longSlice( arguments, 0 );
      args.unshift( dst );
    }
    else
    {
      dst = arguments[ 0 ];
      args = _.longSlice( arguments, 0 );
    }

    let result = self.Self.AtomWiseHomogeneous /* xxx : rename */
    ({
      onContinue : onContinue0,
      onVectorsBegin,
      onVectorsEnd,
      onAtom : handleAtom,
      args,
      reducing : dop.reducing,
      usingDstAsSrc : dop.usingDstAsSrc,
      usingExtraSrcs : dop.usingExtraSrcs,
    });

    return result;
  }
  else if( dop.takingArguments[ 0 ] > 1 )
  Statics[ routineName ] = Statics[ routineName ] = function AtomWiseHomogeneous()
  {
    let self = this;
    let dst, args;

    if( _.instanceIs( this ) )
    {
      dst = this;
      args = _.longSlice( arguments, 0 );
      args.unshift( dst );
    }
    else
    {
      dst = arguments[ 0 ];
      args = _.longSlice( arguments, 0 );
    }

    let result = self.Self.AtomWiseHomogeneous
    ({
      onVectorsBegin,
      onVectorsEnd,
      onAtom : handleAtom,
      args,
      reducing : dop.reducing,
      usingDstAsSrc : dop.usingDstAsSrc,
      usingExtraSrcs : dop.usingExtraSrcs,
    });

    // _.assert( arguments.length === 2, 'Expects exactly two arguments' );
    // _.assert( _.arrayIs( srcs ) );
    // let result = self.Self.atomWiseHomogeneousZip
    // ({
    //   onAtomsBegin : onVectorsBegin,
    //   onAtomsEnd : onVectorsEnd,
    //   onAtom : handleAtom,
    //   dst,
    //   srcs,
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
//   for( let op in operations.atomWiseHomogeneous )
//   declareAtomWiseHomogeneousRoutine( operations.atomWiseHomogeneous[ op ], op );
//
//   _.assert( Statics.addAtomWise );
//   _.assert( Statics.allFiniteAtomWise );
//
// }

// --
// aliases
// --

let Aliases =
{
  allFiniteAtomWise : 'allFinite',
  anyNanAtomWise : 'anyNan',
  allIntAtomWise : 'allInt',
  allZeroAtomWise : 'allZero',
}

function declareAliases()
{

  for( let name1 in Aliases )
  {
    let name2 = Aliases[ name1 ];
    _.assert( !!Proto[ name1 ] );
    _.assert( !Proto[ name2 ] );
    Proto[ name2 ] = Proto[ name1 ];
  }

}

// --
//
// --

let routines = _.vectorAdapter._routinesMathematical;
let r;
for( r in routines )
{
  let routine = routines[ r ];

  _.assert( _.routineIs( routine ) );

  declareElementsZipRoutine( routine, r );
  declareColWiseCollectingRoutine( routine, r );
  declareRowWiseCollectingRoutine( routine, r );
  declareAtomWiseReducingRoutine( routine, r );
  declareAtomWiseHomogeneousWithScalarRoutines( routine, r );
  declareAtomWiseHomogeneousRoutine( routine, r );

}

// declareAtomWiseHomogeneousRoutines();

declareAliases();

_.classExtend( Self, Proto );

_.assert( _.routineIs( Statics.addAtomWise ) );
_.assert( _.routineIs( Self.prototype.allFiniteAtomWise ) );

_.assert( _.routineIs( Self.prototype.reduceToMaxValueColWise ) );
_.assert( _.routineIs( Self.prototype.reduceToMaxValueRowWise ) );
_.assert( _.routineIs( Self.prototype.addAtomWise ) );
_.assert( _.routineIs( Self.prototype.addScalar ) );
_.assert( _.routineIs( Self.addAtomWise ) );

_.assert( !Self.prototype.isValidZip );
_.assert( !Self.prototype.anyNanZip );
_.assert( !Self.prototype.allFiniteZip );

_.assert( !Self.prototype.isValidAtomWise );
_.assert( _.routineIs( Self.prototype.anyNanAtomWise ) );
_.assert( _.routineIs( Self.prototype.allFiniteAtomWise ) );

_.assert( !Self.prototype.isValid );
_.assert( _.routineIs( Self.prototype.anyNan ) );
_.assert( _.routineIs( Self.prototype.allFinite ) );

})();
