( function _Jpg_test_s_( ) {

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

  _.include( 'wTesting' );

  require( '../l5_space/Main.s' );

}

//

var _ = _global_.wTools.withArray.Float32;
var space = _.Space;
var vector = _.vector;
var vec = _.vector.fromArray;
var fvec = function( src ){ return _.vector.fromArray( new Float32Array( src ) ) }
var ivec = function( src ){ return _.vector.fromArray( new Int32Array( src ) ) }
var avector = _.avector;

var sqr = _.sqr;
var sqrt = _.sqrt;

//

function byteToHex( test )
{
  var space = _.Space.make([ 3, 3 ]);

  // Input is string

  test.case = 'simple - Same numbers'; /* */

  var byte = '00001';
  var hex = space.byteToHex( byte );
  test.identical( hex, '01' );

  var byte = '03';
  var hex = space.byteToHex( byte );
  test.identical( hex, '03' );

  test.case = 'simple - numbers > 9'; /* */

  var byte = '000010';
  var hex = space.byteToHex( byte );
  test.identical( hex, '0A' );

  var byte = '11';
  var hex = space.byteToHex( byte );
  test.identical( hex, '0B' );

  var byte = '15';
  var hex = space.byteToHex( byte );
  test.identical( hex, '0F' );

  var byte = '16';
  var hex = space.byteToHex( byte );
  test.identical( hex, '10' );

  var byte = '17';
  var hex = space.byteToHex( byte );
  test.identical( hex, '11' );

  // Input is number

  test.case = 'simple'; /* */

  var byte = 12;
  var hex = space.byteToHex( byte );
  test.identical( hex, '0C' );

  var byte = 13;
  var hex = space.byteToHex( byte );
  test.identical( hex, '0D' );

  test.case = 'numbers > 16'; /* */

  var byte = 101;
  var hex = space.byteToHex( byte );
  test.identical( hex, '65' );

  var byte = 112;
  var hex = space.byteToHex( byte );
  test.identical( hex, '70' );

  var byte = 154;
  var hex = space.byteToHex( byte );
  test.identical( hex, '9A' );

  var byte = 1601;
  var hex = space.byteToHex( byte );
  test.identical( hex, '41' );

  var byte = 177;
  var hex = space.byteToHex( byte );
  test.identical( hex, 'B1' );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.byteToHex( 1 ));
  var space = NaN;
  test.shouldThrowErrorSync( () => space.byteToHex( 2 ));
  var space = null;
  test.shouldThrowErrorSync( () => space.byteToHex( 3 ));
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.byteToHex( 4 ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.byteToHex( ));
  test.shouldThrowErrorSync( () => space.byteToHex( 5, 6 ));
  test.shouldThrowErrorSync( () => space.byteToHex( 5, '6', 7 ));
  test.shouldThrowErrorSync( () => space.byteToHex( [ 0, 1 ]));
  test.shouldThrowErrorSync( () => space.byteToHex( null ));
  test.shouldThrowErrorSync( () => space.byteToHex( undefined ));

}

//

function binaryToByte( test )
{
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'Positive numbers'; /* */

  var byte = '1';
  var hex = space.binaryToByte( byte );
  test.identical( hex, 1 );

  var byte = '10';
  var hex = space.binaryToByte( byte );
  test.identical( hex, 2 );

  var byte = '11';
  var hex = space.binaryToByte( byte );
  test.identical( hex, 3 );

  var byte = '100';
  var hex = space.binaryToByte( byte );
  test.identical( hex, 4 );

  var byte = '111';
  var hex = space.binaryToByte( byte );
  test.identical( hex, 7 );

  test.case = 'simple - numbers > 9'; /* */

  var byte = '11011';
  var hex = space.binaryToByte( byte );
  test.identical( hex, 27 );

  var byte = '11101010';
  var hex = space.binaryToByte( byte );
  test.identical( hex, 234 );

  test.case = 'Negative Numbers'; /* */

  var byte = '0';
  var hex = space.binaryToByte( byte );
  test.identical( hex, - 1 );

  var byte = '01';
  var hex = space.binaryToByte( byte );
  test.identical( hex, - 2 );

  test.case = 'numbers > 16'; /* */

  var byte = '00';
  var hex = space.binaryToByte( byte );
  test.identical( hex, - 3 );

  var byte = '011';
  var hex = space.binaryToByte( byte );
  test.identical( hex, - 4 );

  var byte = '000';
  var hex = space.binaryToByte( byte );
  test.identical( hex, - 7 );

  var byte = '00100';
  var hex = space.binaryToByte( byte );
  test.identical( hex, - 27 );

  var byte = '00010101';
  var hex = space.binaryToByte( byte );
  test.identical( hex, - 234 );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.binaryToByte( '1' ));
  var space = NaN;
  test.shouldThrowErrorSync( () => space.binaryToByte( '2' ));
  var space = null;
  test.shouldThrowErrorSync( () => space.binaryToByte( '3' ));
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.binaryToByte( '4' ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.binaryToByte( ));
  test.shouldThrowErrorSync( () => space.binaryToByte( '01', '11' ));
  test.shouldThrowErrorSync( () => space.binaryToByte( '01', '11', '100' ));
  test.shouldThrowErrorSync( () => space.binaryToByte( [ 0, 1 ]));
  test.shouldThrowErrorSync( () => space.binaryToByte( null ));
  test.shouldThrowErrorSync( () => space.binaryToByte( undefined ));
  test.shouldThrowErrorSync( () => space.binaryToByte( 10 ));

}

//

function increaseBinary( test )
{
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'Positive numbers'; /* */

  var byte = '1';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '10' );

  var byte = '10';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '11' );

  var byte = '11';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '100' );

  var byte = '100';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '101' );

  var byte = '111';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '1000' );

  test.case = 'simple - numbers > 9'; /* */

  var byte = '11011';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '11100' );

  var byte = '11101010';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '11101011' );

  test.case = 'Positive Numbers starting with zeros'; /* */

  var byte = '0';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '1' );

  var byte = '01';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '10' );

  test.case = 'numbers > 16'; /* */

  var byte = '00';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '01' );

  var byte = '011';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '100' );

  var byte = '000';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '001' );

  var byte = '00100';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '00101' );

  var byte = '00010101';
  var hex = space.increaseBinary( byte );
  test.identical( hex, '00010110' );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.increaseBinary( '1' ));
  var space = NaN;
  test.shouldThrowErrorSync( () => space.increaseBinary( '2' ));
  var space = null;
  test.shouldThrowErrorSync( () => space.increaseBinary( '3' ));
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.increaseBinary( '4' ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.increaseBinary( ));
  test.shouldThrowErrorSync( () => space.increaseBinary( '01', '11' ));
  test.shouldThrowErrorSync( () => space.increaseBinary( '01', '11', '100' ));
  test.shouldThrowErrorSync( () => space.increaseBinary( [ 0, 1 ]));
  test.shouldThrowErrorSync( () => space.increaseBinary( null ));
  test.shouldThrowErrorSync( () => space.increaseBinary( undefined ));
  test.shouldThrowErrorSync( () => space.increaseBinary( 10 ));

}

//

function decodeHuffman( test )
{
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'Test huffman decoding'; /* */

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
  hfTables.set( 'Table2Values', [ 0, 1, 2, 3, 4, 5 ] )

  var imageS = '0111010101111001111001011000';
  space.decodeHuffman( components, frameData, hfTables, imageS, 0 );

  var expected =  [ 2, 7, 3, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];

  test.identical( expected, components.get( 'C1-11' ) );

  test.case = 'Test huffman decoding with zeros'; /* */

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

  var imageS = '01110101011110011110010111001100';
  space.decodeHuffman( components, frameData, hfTables, imageS );

  var expected =  [ 2, 7, 3, 0, 11, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];

  test.identical( expected, components.get( 'C1-11' ) );

  test.case = 'Index > 0'; /* */

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

  var imageS = 'START:01110101011110011110010111001100';
  space.decodeHuffman( components, frameData, hfTables, imageS, 6 );

  var expected =  [ 2, 7, 3, 0, 11, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ,0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];

  test.identical( expected, components.get( 'C1-11' ) );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Code not found'; /* */

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

  var imageS = 'START:0111010101111001111001011100110111';

  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, imageS ) );

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, imageS ) );
  var space = NaN;
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, imageS ) );
  var space = null;
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, imageS ) );
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, imageS ) );

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.decodeHuffman(  ) );
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables ) );
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, imageS, 0, 1 ) );
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, 0 ) );
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, null ) );
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, NaN ) );
  test.shouldThrowErrorSync( () => space.decodeHuffman( components, frameData, hfTables, undefined ) );


}

//

function dequantizeVector( test )
{
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'One dequantization Table'; /* */

  var components = new Map();
  components.set( 'C1', [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] );

  var frameData = new Map();
  frameData.set( 'C1QT', 1 );

  var qTables = new Map();
  qTables.set( 'Table1', [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] );

  space.dequantizeVector( components, frameData, qTables );

  var expected = [ 10, 18, 24, 28, 30, 30, 28, 24, 18, 10 ];

  test.identical( expected, components.get( 'C1' ) );

  test.case = 'Two dequantization Tables'; /* */

  var components = new Map();
  components.set( 'C1', [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] );
  components.set( 'C2', [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 11, 12, 13 ] );

  var frameData = new Map();
  frameData.set( 'C1QT', 0 );
  frameData.set( 'C2QT', 1 );

  var qTables = new Map();
  qTables.set( 'Table0', [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] );
  qTables.set( 'Table1', [ 1, 0, 3, 0, 5, 0, 7, 0, 9, 0, -1, 0, -1 ] );

  space.dequantizeVector( components, frameData, qTables );

  var expected1 = [ 10, 18, 24, 28, 30, 30, 28, 24, 18, 10 ];
  var expected2 = [ 10, 0, 24, 0, 30, 0, 28, 0, 18, 0, -11, 0, -13 ];

  test.identical( expected1, components.get( 'C1' ) );
  test.identical( expected2, components.get( 'C2' ) );

  test.case = 'Dequantization Divide values by 2'; /* */

  var components = new Map();
  components.set( 'C1', [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] );
  components.set( 'C2', [ 10, 20 ,30, 40, 50, 60, 70, 80, 90, 100 ] );

  var frameData = new Map();
  frameData.set( 'C1QT', 1 );
  frameData.set( 'C2QT', 1 );

  var qTables = new Map();
  qTables.set( 'Table1', [ 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5 ] );

  space.dequantizeVector( components, frameData, qTables );

  var expected1 = [ 5, 4.5, 4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5 ];
  var expected2 = [ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ];

  test.identical( expected1, components.get( 'C1' ) );
  test.identical( expected2, components.get( 'C2' ) );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Quantization table and component have different length'; /* */

  var components = new Map();
  components.set( 'C1', [ 10, 9, 8, 7 ] );

  var frameData = new Map();
  frameData.set( 'C1QT', 1 );

  var qTables = new Map();
  qTables.set( 'Table1', [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] );

  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData, qTables ) );

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData, qTables ) );
  var space = NaN;
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData, qTables ) );
  var space = null;
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData, qTables ) );
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData, qTables ) );

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.dequantizeVector( ) );
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData ) );
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData, qTables, 0 ) );
  test.shouldThrowErrorSync( () => space.dequantizeVector( null, frameData, qTables ) );
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, undefined, qTables ) );
  test.shouldThrowErrorSync( () => space.dequantizeVector( components, frameData, NaN ) );

}

//

function zigzagOrder( test )
{
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'zigzag reorder'; /* */
  var components = new Map();
  components.set( 'C1', [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
  35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63 ] );
  components.set( 'C2', 'second comp' );
  space.zigzagOrder( components );

  var expected =  _.Space.make( [ 8, 8 ] ).copy
    ([
      0,   1,  5,  6, 14, 15, 27, 28,
      2,   4,  7, 13, 16, 26, 29, 42,
      3,   8, 12, 17, 25, 30, 41, 43,
      9,  11, 18, 24, 31, 40, 44, 53,
      10, 19, 23, 32, 39, 45, 52, 54,
      20, 22, 33, 38, 46, 51, 55, 60,
      21, 34, 37, 47, 50, 56, 59, 61,
      35, 36, 48, 49, 57, 58, 62, 63
    ]);
  test.identical( expected, components.get( 'C1' ) );

  test.case = 'new component'; /* */
  components.set( 'C3', [ 0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, -14, -15, -16, -17, -18, -19, -20, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 1, 1, 1, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63 ] );
  space.zigzagOrder( components );

  var expected =  _.Space.make( [ 8, 8 ] ).copy
    ([
      0,    -1,  -5,  -6, -14, -15, -1,  0,
      -2,   -4,  -7, -13, -16, -1,  0,  1,
      -3,   -8, -12, -17, -1,  0,  1, 43,
      -9,  -11, -18,  -1,  0,  1, 44, 53,
      -10, -19,  -1,   0,  1, 45, 52, 54,
      -20,  -1,   0,   1, 46, 51, 55, 60,
      -1,    0,   1,  47, 50, 56, 59, 61,
      0,     1,  48,  49, 57, 58, 62, 63
    ]);
  test.identical( expected, components.get( 'C3' ) );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.zigzagOrder( components ));
  var space = NaN;
  test.shouldThrowErrorSync( () => space.zigzagOrder( components ));
  var space = null;
  test.shouldThrowErrorSync( () => space.zigzagOrder( components ));
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.zigzagOrder( components ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.zigzagOrder( ));
  test.shouldThrowErrorSync( () => space.zigzagOrder( '01', '11' ));
  test.shouldThrowErrorSync( () => space.zigzagOrder( '01', '11', '100' ));
  test.shouldThrowErrorSync( () => space.zigzagOrder( [ 0, 1 ]));
  test.shouldThrowErrorSync( () => space.zigzagOrder( null ));
  test.shouldThrowErrorSync( () => space.zigzagOrder( undefined ));
  test.shouldThrowErrorSync( () => space.zigzagOrder( 10 ));

}

//

function iDCT( test )
{
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'Pixeled A'; /* */

  var DCT =  _.Space.make( [ 8, 8 ] ).copy
    ([
      6.1917, -0.3411, 1.2418, 0.1492, 0.1583, 0.2742, -0.0724, 0.0561,
      0.2205, 0.0214, 0.4503, 0.3947, -0.7846, -0.4391, 0.1001, -0.2554,
      1.0423, 0.2214, -1.0017, -0.2720, 0.0789, -0.1952, 0.2801, 0.4713,
      -0.2340, -0.0392, -0.2617, -0.2866, 0.6351, 0.3501, -0.1433, 0.3550,
      0.2750, 0.0226, 0.1229, 0.2183, -0.2583, -0.0742, -0.2042, -0.5906,
      0.0653, 0.0428, -0.4721, -0.2905, 0.4745, 0.2875, -0.0284, -0.1311,
      0.3169, 0.0541, -0.1033, -0.0225, -0.0056, 0.1017, -0.1650, -0.1500,
      -0.2970, -0.0627, 0.1960, 0.0644, -0.1136, -0.1031, 0.1887, 0.1444
    ]);

  var expected = _.Space.make( [ 8, 8 ] ).copy
    ([
      1, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 0, 1, 1, 1, 1,
      1, 1, 1, 0, 0, 1, 1, 1,
      1, 1, 0, 1, 0, 1, 1, 1,
      1, 1, 0, 0, 0, 1, 1, 1,
      1, 0, 1, 1, 1, 0, 1, 1,
      1, 0, 1, 1, 1, 0, 1, 1,
      1, 1, 1, 1, 1, 1, 1, 1
    ]);

  var result = space.iDCT( DCT );

  // Result values clamped to 0 or 1 to simplify
  for( var i = 0; i < 8; i ++ )
  {
    for( var j= 0; j < 8; j ++ )
    {
      result.atomSet( [ i, j ], Math.round( result.atomGet( [ i, j ] ) - 128 ) );
    }
  }

  test.equivalent( expected, result );

  test.case = 'Matlab idct2 function results'; /* */

  var DCT =  _.Space.make( [ 8, 8 ] ).copy
    ([
      0, 1, 2, 3, 4, 5, 6, 7,
      9, 10, 11, 12, 13, 14, 15, 16,
      17, 18, 19, 20, 21, 22, 23, 24,
      25, 26, 27, 28, 29, 30, 31, 32,
      33, 34, 35, 36, 37, 38, 39, 40,
      41, 42, 43, 44, 45, 46, 47, 48,
      49, 50, 51, 52, 52, 53, 54, 55,
      56, 57, 58, 59, 60, 61, 62, 63
    ]);

  var expected = _.Space.make( [ 8, 8 ] ).copy
    ([
      179.0734, -64.6687, 42.8731, -19.4514, 22.4328, -4.9924, 12.1141, 3.8933,
      -177.6313, 52.2208, -39.3697, 15.1722, -21.1157, 2.6662, -12.0943, -4.8515,
      70.4115, -22.0668, 15.9454, -6.6843, 8.4996, -1.2744, 4.8175, 1.7289,
      -59.5304, 17.2063, -13.1140, 5.0019, -7.0485, 0.8328, -4.0583, -1.6426,
      31.2829, -10.6668, 7.3399, -3.0276, 3.8594, -0.7856, 2.0954, 0.7948,
      -26.5498, 8.0404, -5.9845, 2.0139, -3.1798, 0.5189, -1.7513, -0.8426,
      10.4772, -4.5652, 2.7482, -1.1179, 1.3881, -0.5072, 0.6562, 0.2816,
      -6.8987, 1.6563, -1.4462, 0.3219, -0.7852, 0.0635, -0.4494, -0.2760
    ]);

  var result = space.iDCT( DCT );

  for( var i = 0; i < 8; i ++ )
  {
    for( var j= 0; j < 8; j ++ )
    {
      result.atomSet( [ i, j ], result.atomGet( [ i, j ] ) - 128 );
    }
  }

  test.equivalent( expected, result );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.iDCT( components ));
  var space = NaN;
  test.shouldThrowErrorSync( () => space.iDCT( components ));
  var space = null;
  test.shouldThrowErrorSync( () => space.iDCT( components ));
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.iDCT( components ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.iDCT( ));
  test.shouldThrowErrorSync( () => space.iDCT( '01', '11' ));
  test.shouldThrowErrorSync( () => space.iDCT( '01', '11', '100' ));
  test.shouldThrowErrorSync( () => space.iDCT( [ 0, 1 ]));
  test.shouldThrowErrorSync( () => space.iDCT( null ));
  test.shouldThrowErrorSync( () => space.iDCT( undefined ));
  test.shouldThrowErrorSync( () => space.iDCT( 10 ));

}

iDCT.accuracy = 1E-3;

//

function setSameSize( test )
{
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'Component of same size'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 1 );
  frameData.set( 'hMax', 1 );
  frameData.set( 'C1H', 1 );
  frameData.set( 'C1V', 1 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component smaller than block in vertical direction'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 2 );
  frameData.set( 'hMax', 1 );
  frameData.set( 'C1H', 1 );
  frameData.set( 'C1V', 1 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 4, 2 ]).copy
  ([
    0, 1,
    0, 1,
    4, 5,
    4, 5
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component smaller than block in horizontal direction'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 1 );
  frameData.set( 'hMax', 2 );
  frameData.set( 'C1H', 1 );
  frameData.set( 'C1V', 1 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 2, 4 ]).copy
  ([
    0, 0, 1, 1,
    4, 4, 5, 5
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component smaller than block in both directions'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 2 );
  frameData.set( 'hMax', 2 );
  frameData.set( 'C1H', 1 );
  frameData.set( 'C1V', 1 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 4, 4 ]).copy
  ([
    0, 0, 1, 1,
    0, 0, 1, 1,
    4, 4, 5, 5,
    4, 4, 5, 5
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component in 2 pieces - horizontal'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));
  components.set( 'C1-12', _.Space.make([ 2, 2 ]).copy
  ([
    2, 3,
    6, 7
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 1 );
  frameData.set( 'hMax', 2 );
  frameData.set( 'C1H', 2 );
  frameData.set( 'C1V', 1 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 2, 4 ]).copy
  ([
    0, 1, 2, 3,
    4, 5, 6, 7,
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component in 2 pieces - horizontal and expanded'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));
  components.set( 'C1-12', _.Space.make([ 2, 2 ]).copy
  ([
    2, 3,
    6, 7
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 2 );
  frameData.set( 'hMax', 2 );
  frameData.set( 'C1H', 2 );
  frameData.set( 'C1V', 1 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 4, 4 ]).copy
  ([
    0, 1, 2, 3,
    0, 1, 2, 3,
    4, 5, 6, 7,
    4, 5, 6, 7
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component in 2 pieces - vertical'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));
  components.set( 'C1-21', _.Space.make([ 2, 2 ]).copy
  ([
    2, 3,
    6, 7
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 2 );
  frameData.set( 'hMax', 1 );
  frameData.set( 'C1H', 1 );
  frameData.set( 'C1V', 2 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 4, 2 ]).copy
  ([
    0, 1,
    4, 5,
    2, 3,
    6, 7
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component in 2 pieces - vertical expanded'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));
  components.set( 'C1-21', _.Space.make([ 2, 2 ]).copy
  ([
    2, 3,
    6, 7
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 2 );
  frameData.set( 'hMax', 2 );
  frameData.set( 'C1H', 1 );
  frameData.set( 'C1V', 2 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 4, 4 ]).copy
  ([
    0, 0, 1, 1,
    4, 4, 5, 5,
    2, 2, 3, 3,
    6, 6, 7, 7
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );

  test.case = 'Component in 4 pieces'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    4, 5
  ]));
  components.set( 'C1-12', _.Space.make([ 2, 2 ]).copy
  ([
    2, 3,
    6, 7
  ]));
  components.set( 'C1-21', _.Space.make([ 2, 2 ]).copy
  ([
    8, 9,
    12, 13
  ]));
  components.set( 'C1-22', _.Space.make([ 2, 2 ]).copy
  ([
    10, 11,
    14, 15
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 2 );
  frameData.set( 'hMax', 2 );
  frameData.set( 'C1H', 2 );
  frameData.set( 'C1V', 2 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected = _.Space.make([ 4, 4 ]).copy
  ([
    0, 1, 2, 3,
    4, 5, 6, 7,
    8, 9, 10, 11,
    12, 13, 14, 15
  ]);

  test.identical( expected, finalComps.get( 'C1' ) );
  var space = _.Space.make([ 3, 3 ]);

  test.case = 'Two different components'; /* */

  var components = new Map();
  components.set( 'C1-11', _.Space.make([ 2, 2 ]).copy
  ([
    0, 1,
    2, 3
  ]));
  components.set( 'C2-11', _.Space.make([ 2, 2 ]).copy
  ([
    1, 1,
    1, 1
  ]));
  components.set( 'C2-12', _.Space.make([ 2, 2 ]).copy
  ([
    2, 2,
    2, 2
  ]));
  components.set( 'C2-21', _.Space.make([ 2, 2 ]).copy
  ([
    3, 3,
    3, 3
  ]));
  components.set( 'C2-22', _.Space.make([ 2, 2 ]).copy
  ([
    4, 4,
    4, 4
  ]));

  var frameData = new Map();
  frameData.set( 'vMax', 2 );
  frameData.set( 'hMax', 2 );
  frameData.set( 'C1H', 1 );
  frameData.set( 'C1V', 1 );
  frameData.set( 'C2H', 2 );
  frameData.set( 'C2V', 2 );

  var finalComps = new Map();

  space.setSameSize( components, frameData, finalComps );

  var expected1 = _.Space.make([ 4, 4 ]).copy
  ([
    0, 0, 1, 1,
    0, 0, 1, 1,
    2, 2, 3, 3,
    2, 2, 3, 3
  ]);
  test.identical( expected1, finalComps.get( 'C1' ) );

  var expected2 = _.Space.make([ 4, 4 ]).copy
  ([
    1, 1, 2, 2,
    1, 1, 2, 2,
    3, 3, 4, 4,
    3, 3, 4, 4
  ]);
  test.identical( expected2, finalComps.get( 'C2' ) );

  /* */

  if( !Config.debug )
  return;

  test.case = 'Not space instance'; /* */

  var space = 'space';
  test.shouldThrowErrorSync( () => space.setSameSize( components, frameData, finalComps ) );
  var space = NaN;
  test.shouldThrowErrorSync( () => space.setSameSize( components, frameData, finalComps ) );
  var space = null;
  test.shouldThrowErrorSync( () => space.setSameSize( components, frameData, finalComps ) );
  var space = [ 0, 0, 0 ];
  test.shouldThrowErrorSync( () => space.setSameSize( components, frameData, finalComps ) );

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3, 3 ]);
  test.shouldThrowErrorSync( () => space.setSameSize( ) );
  test.shouldThrowErrorSync( () => space.setSameSize( components, frameData ) );
  test.shouldThrowErrorSync( () => space.setSameSize( components, frameData, finalComps, 0 ) );
  test.shouldThrowErrorSync( () => space.setSameSize( null, frameData, finalComps ) );
  test.shouldThrowErrorSync( () => space.setSameSize( components, undefined, finalComps ) );
  test.shouldThrowErrorSync( () => space.setSameSize( components, frameData, NaN ) );

}


// --
// declare
// --

var Self =
{

  name : 'Tools/Math/Jpg',
  silencing : 1,
  enabled : 1,
  // routine : 'qR',
  // verbosity : 7,

  tests :
  {

    byteToHex : byteToHex,
    binaryToByte : binaryToByte,
    increaseBinary : increaseBinary,

    decodeHuffman : decodeHuffman,
    dequantizeVector : dequantizeVector,
    zigzagOrder : zigzagOrder,
    iDCT : iDCT,

    setSameSize : setSameSize,

    /*
    ycbcrToRGB : ycbcrToRGB,

    decodeJPG : decodeJPG,

    */
  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_global_.wTester.test( Self.name );

})();
