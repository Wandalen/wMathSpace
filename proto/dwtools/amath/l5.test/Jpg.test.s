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
  var space = _.Space.make([ 3,3 ]);

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
  var space = _.vector.from( [ 0, 0, 0 ] );
  test.shouldThrowErrorSync( () => space.byteToHex( 5 ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3,3 ]);
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
  var space = _.Space.make([ 3,3 ]);

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
  var space = _.vector.from( [ 0, 0, 0 ] );
  test.shouldThrowErrorSync( () => space.binaryToByte( '5' ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3,3 ]);
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
  var space = _.Space.make([ 3,3 ]);

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
  var space = _.vector.from( [ 0, 0, 0 ] );
  test.shouldThrowErrorSync( () => space.increaseBinary( '5' ));

  test.case = 'Wrong number/type of args'; /* */

  var space = _.Space.make([ 3,3 ]);
  test.shouldThrowErrorSync( () => space.increaseBinary( ));
  test.shouldThrowErrorSync( () => space.increaseBinary( '01', '11' ));
  test.shouldThrowErrorSync( () => space.increaseBinary( '01', '11', '100' ));
  test.shouldThrowErrorSync( () => space.increaseBinary( [ 0, 1 ]));
  test.shouldThrowErrorSync( () => space.increaseBinary( null ));
  test.shouldThrowErrorSync( () => space.increaseBinary( undefined ));
  test.shouldThrowErrorSync( () => space.increaseBinary( 10 ));

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
    /*

    decodeHuffman : decodeHuffman,
    dequantizeVector : dequantizeVector,
    zigzagOrder : zigzagOrder,
    iDCT : iDCT,
    setSameSize : setSameSize,
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
