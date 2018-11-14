(function _Jpg_s_() {

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
// CONVERSION AND AUXILIARY FUNCTIONS:
//

//Get Image data:
/**
  * Get the array of bytes of a jpg image. Returns the array of bytes.
  *
  * @param { String } jpgPath - Absolute path to the jpg image.
  *
  * @example
  * // returns [ 255, 216, 255, 224, 0, ... ];
  * _.getData( '.../myImages/testImage.jpg' );
  *
  * @returns { Array } Returns the array of bytes of the jpg image.
  * @function getData
  * @throws { Error } An Error if ( arguments.length ) is different than one.
  * @throws { Error } An Error if ( jpgPath ) is not a string.
  * @memberof wTools.wSpace
  */
function getData( jpgPath )
{
  _.assert( arguments.length === 1, 'getData expects only one argument' );
  _.assert( typeof jpgPath === 'string' || jpgPath instanceof String );

  let provider = _.FileProvider.HardDrive();

  let data = provider.fileRead
  ({
    filePath : jpgPath,
    sync : 1,
    encoding : 'buffer.bytes'
  });

  return data;
}

//

//Number to HEX
/**
  * Convert a byte to Hexadecimal. Returns the hexadecimal value.
  *
  * @param { String or Number } byte - The source byte.
  *
  * @example
  * // returns '0B';
  * _.byteToHex( '11' );
  *
  * // returns '11';
  * _.byteToHex( 17 );
  *
  * @returns { String } Returns the string of the hexadecimal number.
  * @function byteToHex
  * @throws { Error } An Error if ( arguments.length ) is different than one.
  * @throws { Error } An Error if ( byte ) is not a string or a number.
  * @memberof wTools.wSpace
  */
function byteToHex( byte )
{
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( byte ) || _.numberIs( byte ) );

  let hexChar = ["0", "1", "2", "3", "4", "5", "6", "7","8", "9", "A", "B", "C", "D", "E", "F"];
  return hexChar[ ( byte >> 4 ) & 0x0f ] + hexChar[ byte & 0x0f ];
}

//

// Binary To Number
/**
  * Convert a binary number ( in a string ) to a decimal number . Returns the decimal number.
  * If the binary number starts by 0, it changes all 0s by 1s and returns the negative number.
  *
  * @param { String } b - The source binary number.
  *
  * @example
  * // returns 27;
  * _.binaryToByte( '11011' );
  *
  * // returns - 27;
  * _.binaryToByte( '00100' );
  *
  * @returns { Number } Returns the decimal number from the binary string.
  * @function binaryToByte
  * @throws { Error } An Error if ( arguments.length ) is different than one.
  * @throws { Error } An Error if ( byte ) is not a string
  * @memberof wTools.wSpace
  */
function binaryToByte( b )
{
  _.assert( arguments.length === 1,'binaryToByte :','Expects only one argument' );
  _.assert( _.strIs( b ),'binaryToByte :','Expects string'  );

  let byte = 0;
  if( b.charAt( 0 ) ==  1  )
  {
    byte = parseInt( b, 2);
  }
  else if( b.charAt( 0 ) == 0 )
  {
    let c = b.replace( /1/g, '2' );
    let d = c.replace( /0/g, '1' );
    let e = d.replace( /2/g, '0' );
    byte = parseInt( e, 2)*( - 1 );
  }
  return byte;
}

//

// Increase binary number
/**
  * Increase a binary number by one. Returns the increased number.
  *
  * @param { String } b - The source binary number.
  *
  * @example
  * // returns '11100';
  * _.increaseBinary( '11011' );
  *
  * // returns '00010110' ;
  * _.binaryToByte( '00010101' );
  *
  * @returns { String } Returns a string with the increased binary number.
  * @function increaseBinary
  * @throws { Error } An Error if ( arguments.length ) is different than one.
  * @throws { Error } An Error if ( byte ) is not a string
  * @memberof wTools.wSpace
  */
function increaseBinary( b )
{
  _.assert( arguments.length === 1,'increaseBinary :','Expects only one argument' );
  _.assert( _.strIs( b ), 'increaseBinary :','Expects string' );

  let newBin = parseInt( b, 2 ) + 1;
  let bin = newBin.toString( 2 );
  while( bin.length < b.length )
  {
    bin = '0' + bin;
  }
  return bin;
}

//

/**
  * Decode one block in a string of bits Huffman encoded.
  *
  * @param { Object } components - Map with Huffman table codes, and were the decoded components will be stored.
  * @param { Object } frameData - Map with number of components and vertical and horizontal sampling.
  * @param { Object } hfTables - Map with Huffman tables.
  * @param { String } imageS - String with the encoded data.
  * @param { Number } index - Position to start the decoding in imageS.
  *
  * @returns { Number } Returns the index were the decoding of the block ended.
  * @function decodeHuffman
  * @throws { Error } An Error if ( arguments.length ) is different than four or five.
  * @throws { Error } An Error if ( imageS ) is not a string
  * @memberof wTools.wSpace
  */
function decodeHuffman( components, frameData, hfTables, imageS, index )
{
  _.assert( 4 <= arguments.length && arguments.length <= 5, 'decodeHuffman :','Expects four or five arguments' );
  _.assert( _.strIs( imageS ), 'decodeHuffman :','Expects image as string of binary code' );

  if( arguments.length === 4 )
  index = 0;

  let i = index;     // counter
  let numOfBytes = imageS.length;
  _.assert( i < numOfBytes, 'decodeHuffman :','Index must be inferior to imageString.length' );

  for( let c = 1; c <= components.get( 'numOfComponents' ); c++ )
  {
    for( let vf = 0; vf < frameData.get( 'C' + String( c ) + 'V' ); vf++ )
    {
      for( let hf = 0; hf < frameData.get( 'C' + String( c ) + 'H' ); hf++ )
      {
        let comp = _.array.makeArrayOfLengthZeroed( 64 );

        // DC
        let Dc = 0;
        let table = components.get( 'C' + String( c ) + 'Dc' );

        //Get HT
        let codes;
        let values;

        for( let t = 1; t <= hfTables.size / 6; t++ )
        {
          if( hfTables.get( 'Table' + t + 'AcDc' ) === Dc )
          {
            if( hfTables.get( 'Table' + t + 'ID' ) === table )
            {
              codes = hfTables.get( 'Table' + t + 'Codes' );
              values = hfTables.get( 'Table' + t + 'Values' );
            }
          }
        }

        let num = '';  // bit sequence
        let code = ''; // huffman code
        let value = ''; // value related to the huffman code
        let diffBinary = '';

        while( code === ''  && num.length < 17 )
        {
          num = num + imageS.charAt( i );

          for( let j = 0; j < codes.length; j++ )
          {
            let binaryCode = codes[ j ];

            if( num === binaryCode.toString() )
            {
              code = num;
              value = values[ j ];
            }
          }
          i = i + 1;
          _.assert( i < numOfBytes + 1, 'decodeHuffman :','DC Huffman code not found' );

          if( num.length === 17 )
          {
            _.assert( value !== '', 'decodeHuffman :', 'DC Huffman code not found' )
          }
        }
        //  logger.log('code', code , 'value', value );

        if( value != '00' )
        {
          for( let f = 0; f < parseInt( value ); f++)
          {
            diffBinary = diffBinary + imageS.charAt( i );
            i = i + 1;
            _.assert( i < numOfBytes + 1, 'decodeHuffman :', 'DC Huffman code not found' );
          }
          Dc = binaryToByte( diffBinary );

          comp[ 0 ] = Dc;
          _.assert( _.numberIs( comp[ 0 ] ) && !isNaN( comp[ 0 ] ) );
        }
        else
        {
          comp[ 0 ] = 0;
        }
        //logger.log(String( c ),'Get', diffBinary, ' for', comp[ 0 ])

        // AC

        let Ac = 1;
        table = components.get( 'C' + String( c ) + 'Ac' );

        //Get HT
        for( let t = 1; t <= hfTables.size / 6; t++ )
        {
          if( hfTables.get( 'Table' + t + 'AcDc' ) === Ac )
          {
            if( hfTables.get( 'Table' + t + 'ID' ) === table )
            {
              codes = hfTables.get( 'Table' + t + 'Codes' );
              values = hfTables.get( 'Table' + t + 'Values' );
            }
          }
        }

        debugger;
        let j = 1;
        value = ''; // value related to the huffman code
        while( j < 64 && value != '00')
        {
          num = '';  // bit sequence
          code = ''; // huffman code
          value = ''; // value related to the huffman code

          while( code === '' && num.length < 17 )
          {
            num = num + imageS.charAt( i );

            for( let r = 0; r < codes.length; r++ )
            {
              let binaryCode = codes[ r ];
              if( num === binaryCode.toString() )
              {
                code = num;
                value = values[ r ];
              }
            }
            i = i + 1;
            _.assert( i < numOfBytes + 1, 'decodeHuffman :', 'AC Huffman code not found' );

            if( num.length === 17 )
            {
              _.assert( value !== '', 'decodeHuffman :', 'AC Huffman code not found' )
            }
          }
          //  logger.log('code', code , 'value', value );

          if( value != '00' )
          {
            let binValue = Number( value ).toString( 2 );

            if( binValue.length < 5 )
            {
              let diffBinary = '';
              for( let f = 0; f < parseInt( value ); f++)
              {
                diffBinary = diffBinary + imageS.charAt( i );
                i = i + 1;
                _.assert( i < numOfBytes + 1, 'decodeHuffman :', 'AC Huffman code not found' );
              }

              let Ac = binaryToByte( diffBinary );
              comp[ j ] = Ac;
              _.assert( _.numberIs( comp[ j ] ) && !isNaN( comp[ j ] ) );
              //  logger.log('Get', diffBinary, ' for', comp[ j ])
            }
            else
            {
              let newValue = '';
              let zeros = '';

              for( let u = 0; u < binValue.length; u++ )
              {
                if( binValue.length - u > 4 )
                {
                  zeros = zeros + binValue.charAt( u );
                }
                else
                {
                  newValue = newValue + binValue.charAt( u );
                }
              }
              let numZeros = parseInt( zeros, 2 );
              for( let z = 0; z < numZeros; z++ )
              {
                comp[ j ] = 0;
                j = j + 1;
              }
              //  logger.log('Get', zeros, ' for', numZeros, ' zeros')
              let diffBinary = '';
              let numNewValue = parseInt( newValue, 2 );

              for( let f = 0; f < numNewValue; f++)
              {
                diffBinary = diffBinary + imageS.charAt( i );
                i = i + 1;
                _.assert( i < numOfBytes + 1, 'decodeHuffman :', 'AC Huffman code not found' );
              }
              let Ac = binaryToByte( diffBinary );

              if( diffBinary === '' )
              Ac = 0;

              comp[ j ] = Ac;

              _.assert( _.numberIs( comp[ j ] ) && !isNaN( comp[ j ] ) );
            }
          }
          j = j + 1;
        }
        components.set( 'C' + String( c ) +'-' + String( vf + 1 ) + String( hf + 1 ), comp );
      }
    }
  }

  index = i;
  return index;
}

//

// Dequantization
/**
  * Dequantize the arrays in the components object with the quantization tables. Returns the
  * dequantized components.
  *
  * @param { Object } components - Map with arrays to dequantize, and were the dequantized components will be stored.
  * @param { Object } frameData - Map with number of components and vertical and horizontal sampling.
  * @param { Object } qTables - Map with Quantization tables.
  *
  * @example
  * // returns [ 10, 18, 24, 28, 30, 30, 28, 24, 18, 10 ];
  * var components = new Map();
  * components.set( 'C1', [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ] );
  * var frameData = new Map();
  * frameData.set( 'C1QT', 1 );
  * var qTables = new Map();
  * qTables.set( 'Table1', [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] );
  * _.dequantizeVector( components, frameData, qTables );
  *
  * @returns { Object } Returns the components object with the dequantized components.
  * @function dequantizeVector
  * @throws { Error } An Error if ( arguments.length ) is different than three.
  * @memberof wTools.wSpace
  */
function dequantizeVector( components, frameData, qTables )
{
  _.assert( arguments.length === 3, 'decodeHuffman :','Expects exactly three arguments' );

  for ( let [ key, value ] of components )
  {
    if( typeof( value ) === 'object')
    {
      let tableIndex = frameData.get( 'C' + key.charAt( 1 )+ 'QT' )

      let quant = qTables.get( 'Table' + String( tableIndex ) );
      Array.from( value );
      _.assert( value.length === quant.length, 'The quantization table and the component must have the same length')
      for( let v = 0; v < value.length; v++ )
      {
        value[ v ] = value[ v ]*quant[ v ];
      }
    }
  }

  return components;
}

//

/**
  * Order the arrays in the components object in zigzag. Returns the ordered components.
  *
  * @param { Object } components - Map with arrays to order, and were the ordered components will be stored.
  *
  * @example
  * // returns  _.Space.make( [ 8, 8 ] ).copy
  *  ([
  *    0,   1,  5,  6, 14, 15, 27, 28,
  *    2,   4,  7, 13, 16, 26, 29, 42,
  *    3,   8, 12, 17, 25, 30, 41, 43,
  *    9,  11, 18, 24, 31, 40, 44, 53,
  *    10, 19, 23, 32, 39, 45, 52, 54,
  *    20, 22, 33, 38, 46, 51, 55, 60,
  *    21, 34, 37, 47, 50, 56, 59, 61,
  *    35, 36, 48, 49, 57, 58, 62, 63
  *  ]);
  * var components = new Map();
  * components.set( 'C1', [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
  * 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63 ] );
  * _.zigzagOrder( components );
  *
  * @returns { Object } Returns the components object with the ordered components.
  * @function zigzagOrder
  * @throws { Error } An Error if ( arguments.length ) is different than one.
  * @memberof wTools.wSpace
  */
function zigzagOrder( components )
{
  _.assert( arguments.length === 1 );
  for ( let [ key, value ] of components )
  {
    if( typeof( value ) === 'object')
    {
      let space = _.Space.make( [ 8, 8 ] );
      Array.from( value );
      let i = [ 0, 0, 1, 2, 1, 0, 0, 1, 2, 3, 4, 3, 2, 1, 0, 0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0, 0, 1, 2,
      3, 4, 5, 6, 7, 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 7, 6, 5, 4, 3, 4, 5, 6, 7, 7, 6, 5, 6, 7, 7 ];
      let j = [ 0, 1, 0, 0, 1, 2, 3, 2, 1, 0, 0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0, 0, 1, 2, 3, 4, 5, 6, 7, 6, 5,
      4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 6, 7, 7, 6, 5, 4, 3, 2, 3, 4, 5, 6, 7, 7, 6, 5, 4, 5, 6, 7, 7, 6, 7 ];

      if( value.length === i.length )
      {
        for( let v = 0; v < value.length; v++ )
        {
          space.atomSet( [ i[ v ], j[ v ] ], value[ v ] );
        }

        components.set( key, space );
      }

    }
  }
}

//

/**
  * Operates the Inverse Discrete Cosine Transform on a matrix. Returns the matrix with the new values.
  *
  * @param { Space } values - src matrix with the input values.
  *
  * @example
  * // returns  _.Space.make( [ 8, 8 ] ).copy
  *  ([
  *    1, 1, 1, 1, 1, 1, 1, 1,
  *    1, 1, 1, 0, 1, 1, 1, 1,
  *    1, 1, 1, 0, 0, 1, 1, 1,
  *    1, 1, 0, 1, 0, 1, 1, 1,
  *    1, 1, 0, 0, 0, 1, 1, 1,
  *    1, 0, 1, 1, 1, 0, 1, 1,
  *    1, 0, 1, 1, 1, 0, 1, 1,
  *    1, 1, 1, 1, 1, 1, 1, 1
  *  ]);
  *
  *  var DCT =  _.Space.make( [ 8, 8 ] ).copy
  *   ([
  *     6.1917, -0.3411, 1.2418, 0.1492, 0.1583, 0.2742, -0.0724, 0.0561,
  *     0.2205, 0.0214, 0.4503, 0.3947, -0.7846, -0.4391, 0.1001, -0.2554,
  *     1.0423, 0.2214, -1.0017, -0.2720, 0.0789, -0.1952, 0.2801, 0.4713,
  *     -0.2340, -0.0392, -0.2617, -0.2866, 0.6351, 0.3501, -0.1433, 0.3550,
  *     0.2750, 0.0226, 0.1229, 0.2183, -0.2583, -0.0742, -0.2042, -0.5906,
  *     0.0653, 0.0428, -0.4721, -0.2905, 0.4745, 0.2875, -0.0284, -0.1311,
  *     0.3169, 0.0541, -0.1033, -0.0225, -0.0056, 0.1017, -0.1650, -0.1500,
  *     -0.2970, -0.0627, 0.1960, 0.0644, -0.1136, -0.1031, 0.1887, 0.1444
  *   ]);
  * _.iDCT( values );
  *
  * @returns { Object } Returns the input space with the discrete cosine transform values.
  * @function iDCT
  * @throws { Error } An Error if ( arguments.length ) is different than one.
  * @throws { Error } An Error if ( values ) is not a space.
  * @memberof wTools.wSpace
  */
function iDCT( values )
{

  function c( u, v )
  {
    if( u === 0 && v === 0 )
    {
      return 1 / 2;
    }
    else if( u === 0 || v === 0  )
    {
      return 1 / Math.sqrt( 2 );
    }
    else
    {
      return 1;
    }
  }

  let space = _.Space.make( [ 8, 8 ] );

  _.assert( _.spaceIs( values ) );

  for( let i = 0; i < 8; i++ )
  {
    for( let j = 0; j < 8; j++ )
    {
      let val = 0;
      for( let u = 0; u < 8; u ++ )
      {
        for( let v = 0; v < 8; v ++ )
        {
          val = val + c( u, v ) * values.atomGet( [ u, v ] ) * Math.cos( Math.PI * u * ( 2 * i + 1 ) / 16 ) * Math.cos( Math.PI * v * ( 2 * j + 1 ) / 16 );
        }
      }

      val = val / 4;
      val = 128 + val; // levelshift
      // val = Math.round( val );

      space.atomSet( [ i, j ], val );
    }
  }
  return space;
}

//

function setSameSize( components, frameData, finalComps )
{
  _.assert( arguments.length === 3, 'setSameSize :','Expects exactly three arguments' );
  let oldComp = '';
  let compPart = 0;
  let vMax = frameData.get( 'vMax' );  // max number of subBlocks per block in vertical
  let hMax = frameData.get( 'hMax' );  // max number of subBlocks per block in horizontal
  for ( let [ key, value ] of components )
  {

    if( typeof( value ) === 'object')
    {
      let comp = key.slice( 0, 2 );
      let dims = _.Space.dimsOf( value );

      if( comp !== oldComp )
      {
        var newComp = _.Space.make( [ dims[ 0 ]*vMax, dims[ 1 ]*hMax ] );
        oldComp = comp;
      }

      let h = frameData.get( comp + 'H' );  // number of subBlocks per block in vertical for the component
      let v = frameData.get( comp + 'V' );  // number of subBlocks per block in horizontal for the component
      let place = key.slice( key.length - 2 );

      let hTimes = hMax / h;
      let vTimes = vMax / v;

      for( let x = 0; x < dims[ 0 ]; x++ )
      {
        for( let y = 0; y < dims[ 1 ]; y++ )
        {
          for( let ht = 0; ht < hTimes; ht++ )
          {
            for( let vt = 0; vt < vTimes; vt++ )
            {
              let posx = x * vTimes + vt + dims[ 0 ] * ( Number( place.charAt( 0 ) ) - 1 );
              let posy = y * hTimes + ht + dims[ 1 ] * ( Number( place.charAt( 1 ) ) - 1 );

              newComp.atomSet( [ posx, posy ], value.atomGet( [ x, y ] ) );
            }
          }
        }
      }

      finalComps.set( comp, newComp );
    }
  }
}

//

function ycbcrToRGB( finalComps )
{
  _.assert( arguments.length === 1, 'ycbcrToRGB expects exactly one argument')
  _.assert( finalComps.size === 3 || finalComps.size === 6 );

  let yComp = finalComps.get( 'C1' );
  let yDimh = _.Space.dimsOf( yComp )[ 1 ];
  let yDimv = _.Space.dimsOf( yComp )[ 0 ];
  let cbComp = finalComps.get( 'C2' );
  let cbDimh = _.Space.dimsOf( cbComp )[ 1 ];
  let cbDimv = _.Space.dimsOf( cbComp )[ 0 ];
  let crComp = finalComps.get( 'C3' );
  let crDimh = _.Space.dimsOf( crComp )[ 1 ];
  let crDimv = _.Space.dimsOf( crComp )[ 0 ];

  _.assert( yDimh == crDimh );
  _.assert( yDimh == cbDimh);
  _.assert( yDimv == crDimv );
  _.assert( yDimv == cbDimv);

  let r = _.Space.make( [ yDimv, yDimh ] );
  let g = _.Space.make( [ yDimv, yDimh ] );
  let b = _.Space.make( [ yDimv, yDimh ] );

  for( let x = 0; x < yDimv; x++ )
  {
    for( let y = 0; y < yDimh; y++ )
    {
      let yValue = yComp.atomGet( [ x, y ] );
      let cbValue = cbComp.atomGet( [ x, y ] );
      let crValue = crComp.atomGet( [ x, y ] );
      let rValue = yValue + 1.402 * ( crValue - 128 );
      rValue = Math.round( rValue );

      if( rValue < 0 )
      rValue = 0;

      if( rValue > 255 )
      rValue = 255;

      _.assert( 0 <= rValue && rValue <= 255 );
      r.atomSet( [ x, y ], rValue );

      let gValue = yValue - 0.34414 * ( cbValue - 128 ) - 0.71414 * ( crValue - 128 );
      gValue = Math.round( gValue );

      if( gValue < 0 )
      gValue = 0;

      if( gValue > 255 )
      gValue = 255;

      _.assert( 0 <= gValue && gValue <= 255 );
      g.atomSet( [ x, y ], gValue );

      let bValue = yValue + 1.772 * ( cbValue - 128 );
      bValue = Math.round( bValue );

      if( bValue < 0 )
      bValue = 0;

      if( bValue > 255 )
      bValue = 255;

      _.assert( 0 <= bValue && bValue <= 255 );
      b.atomSet( [ x, y ], bValue );
      //logger.log(bValue)

    }
  }

  finalComps.set( 'R', r );
  finalComps.set( 'G', g );
  finalComps.set( 'B', b );
  finalComps.delete( 'C1' );
  finalComps.delete( 'C2' );
  finalComps.delete( 'C3' );
}

//

function decodeJPG( data )
{
  _.assert( arguments.length === 1, 'decodeJPG expects only one argument' );
  _.assert( _.longIs( data ), 'decodeJPG expects long' );

  let dataViewByte = Array.from( data );

  let dataViewHex = Array.from( data ).slice();

  // SET MARKERS:

  logger.log( 'IMAGE MARKERS')
  let hfTables = new Map();
  let hf = 0;
  let qTables = new Map();
  let qt = 0;
  let startFrame = 0; // Start of Frame
  let startScan = 0; // Start of Scan
  let endImage = 0; // End of Image

  for( let i = 0; i < dataViewByte.length; i++ )
  {
    dataViewHex[ i ] = byteToHex( dataViewHex[ i ] );
    //logger.log( dataView[ i ]);
    if( i > 0 && dataViewHex[ i - 1 ] === 'FF' )
    {
      if( dataViewHex[ i ] === 'D8' )
      {
        logger.log('Start of Image', i );
      }
      else if( dataViewHex[ i ] === 'DB' )
      {
        logger.log('Quantization Table', i );
        let length = dataViewByte[ i + 1 ]*256 + dataViewByte[ i + 2 ];
        qTables.set( 'Table' + String( qt ) + 'start', i + 3 );
        qTables.set( 'Table' + String( qt ) + 'length', length );
        qt = qt + 1;
      }
      else if( dataViewHex[ i ] === 'C4' )
      {
        logger.log('Huffman Table', i );
        hfTables.set( 'Table' + String( hf + 1 ) + 'start', i + 2 );
        let length = dataViewByte[ i + 1 ]*256 + dataViewByte[ i + 2 ];
        hfTables.set( 'Table' + String( hf + 1 ) + 'end', i + length );
        hf = hf + 1;
      }
      else if( dataViewHex[ i ] === 'DC' )
      {
        logger.log('Number of lines', i );
      }
      else if( dataViewHex[ i ] === 'DA' )
      {
        logger.log('Start of Scan', i );
        startScan = i + 1;
      }
      else if( dataViewHex[ i ] === 'C0' )
      {
        logger.log('Start of Frame', i );
        startFrame = i + 1;
      }
      else if( dataViewHex[ i ] === 'DD' )
      {
        logger.log('Restart interval', i );
      }
      else if( dataViewHex[ i ] === 'FE' )
      {
        logger.log('Comment', i );
      }
      else if( dataViewHex[ i ] === 'E0' )
      {
        logger.log('JFIF specification', i );
      }
      else if( dataViewHex[ i ] === 'D9' )
      {
        logger.log('End of image', i );
        endImage = i;
      }
      else if( dataViewHex[ i ] === '00' )
      {
        logger.log('Stuff byte - remove 00 ', i );
        //dataViewHex[ i ] = '';º11ss
        dataViewHex.splice( i, 1 );
        dataViewByte.splice( i, 1 );
      }
      else
      {
        logger.log( 'Marker without meaning - remove FF: FF ',dataViewHex[ i ] )
        // dataViewHex[ i - 1 ] = '';
        dataViewHex.splice( i - 1, 1 );
        dataViewByte.splice( i - 1, 1 );
      }
    }
  }

  _.assert( hf === 4 || hf === 2, 'JPG doesn´t have 2 or 4 DHT markers')

  // GET IMAGE ( Scan ) DATA:

  let image = _.array.makeArrayOfLengthZeroed( endImage - startScan + 1 );
  let imageH = _.array.makeArrayOfLengthZeroed( endImage - startScan + 1 );
  let imageB = _.array.makeArrayOfLengthZeroed( endImage - startScan + 1 );

  for( let i = 0; i < image.length; i++ )
  {
    image[ i ] = dataViewByte[ startScan + i - 2 ];
    imageH[ i ] = dataViewHex[ startScan + i - 2 ];
    imageB[ i ] = ( dataViewByte[ startScan + i - 2 ] ).toString( 2 );
  }

  //Number of components
  let components = new Map();
  let numOfComponents = image[ 4 ];

  for( let c = 0; c < numOfComponents; c++ )
  {
    // Get Number of HT
    let ac = '';
    let dc = '';
    let component = image[ 5 + 2*c ];
    let type = imageB[ 5 + 2*c + 1 ];

    for( let u = 0; u < type.length; u++ )
    {
      if( type.length < 4 )
      {
        dc = 0;
        ac = ac + type.charAt( u );
      }
      else
      {
        if( type.length - u > 4)
        {
          dc = dc + type.charAt( u );
        }
        else
        {
          ac = ac + type.charAt( u )
        }
      }
    }

    components.set( 'numOfComponents', numOfComponents );
    components.set( 'C' + String( component ) + 'Ac', parseInt( ac, 10 ) );
    components.set( 'C' + String( component ) + 'Dc', parseInt( dc, 10 ) );
  }

  // GET FRAME INFORMATION:

  let frameData = new Map();
  let lengthFrame = 8 + numOfComponents * 3;
  let frameB = _.array.makeArrayOfLength( lengthFrame );
  let frameH = _.array.makeArrayOfLength( lengthFrame );

  for( let f = 0; f < lengthFrame; f ++ )
  {
    frameB[ f ] = dataViewByte[ startFrame + f ];
    frameH[ f ] = dataViewHex[ startFrame + f ];
  }

  let imageHeight = frameB[ 3 ]*256 + frameB[ 4 ];
  let imageWidth = frameB[ 5 ]*256 + frameB[ 6 ];
  _.assert( imageHeight > 0 && imageWidth > 0, 'Image height and width must be superior to zero' );
  let numOfComponentsF = frameB[ 7 ];
  _.assert( numOfComponentsF === numOfComponents, 'Different number of components between frame and scan' );

  // Get Sampling factors and Quantization table code
  let vMax = 0;
  let hMax = 0;
  let numOfQT = 0;
  let oldQT = '';

  for( let cf = 0; cf < numOfComponents; cf++ )
  {
    let component = frameB[ 8 + 3*cf ];
    let samplingF = Number(  frameB[ 8 + 3*cf + 1 ] ).toString( 2 );
    let qT = frameB[ 8 + 3*cf + 2 ];

    if( oldQT !== qT )
    numOfQT = numOfQT + 1;

    oldQT = qT;

    let h = '';
    let v = '';

    for( let u = 0; u < samplingF.length; u++ )
    {
      if( samplingF.length < 4 )
      {
        h = 0;
        v = v + samplingF.charAt( u );
      }
      else
      {
        if( samplingF.length - u > 4)
        {
          h = h + samplingF.charAt( u );
        }
        else
        {
          v = v + samplingF.charAt( u )
        }
      }
    }

    h = parseInt( h, 2);
    v = parseInt( v, 2);

    if( v > vMax )
    vMax = v;

    if( h > hMax )
    hMax = h;

    frameData.set( 'numOfComponents', numOfComponents );
    frameData.set( 'numOfQT', numOfQT );
    frameData.set( 'vMax', vMax );
    frameData.set( 'hMax', hMax );
    frameData.set( 'C' + String( component ) + 'H', h );
    frameData.set( 'C' + String( component ) + 'V', v );
    frameData.set( 'C' + String( component ) + 'QT', qT );
  }
  // GET QUANTIZATION TABLES:

  for( let q = 0; q < qt; q++ )
  {
    let length = qTables.get( 'Table' + String( q ) + 'length' );
    let numOfQTables = length / 65;
    numOfQTables = Math.round( numOfQTables );

    for( let t = 0; t < numOfQTables; t++ )
    {
      let qTable = _.array.makeArrayOfLengthZeroed( 64 );
      for( let e = 0; e < 64; e++ )
      {
        qTable[ e ] = dataViewByte[ qTables.get( 'Table' + String( q ) + 'start' ) + e + 65 * t + 1];
      }
      qTables.set( 'Table' + String( dataViewByte[ qTables.get( 'Table' + String( q ) + 'start' ) + 65 * t ] ), qTable )
    }
  }

  // GET HUFFMAN TABLES:

  function getHuffmanTables( dataViewByte, hfTables )
  {
    let numOfTables = hfTables.size / 2;
    for( let i = 1; i <= numOfTables; i++ )
    {
      let hfTableArray = _.array.makeArrayOfLengthZeroed( hfTables.get( 'Table' + String( i ) + 'end' ) - hfTables.get( 'Table' + String( i ) + 'start' ) );
      let hfTableArrayH = _.array.makeArrayOfLengthZeroed( hfTables.get( 'Table' + String( i ) + 'end' ) - hfTables.get( 'Table' + String( i ) + 'start' ) );


      for( let j = 0; j < hfTableArray.length; j++ )
      {
        hfTableArray[ j ] = dataViewByte[ hfTables.get( 'Table' + String( i ) + 'start' ) + j + 1 ];
        hfTableArrayH[ j ] = dataViewHex[ hfTables.get( 'Table' + String( i ) + 'start' ) + j + 1 ];
      }

      // Get Type And Number of HT
      let type = hfTableArray[ 0 ];
      let typeB = type.toString( 2 );
      let acdc = '';
      let id = '';

      for( let u = 0; u < typeB.length; u++ )
      {
        if( typeB.length < 4 )
        {
          acdc = 0;
        }
        else if( typeB.length - u === 5 )
        {
          acdc = acdc + typeB.charAt( u );
        }

        if( typeB.length - u < 4 )
        {
          id = id + typeB.charAt( u );
        }
      }

      hfTables.set( 'Table' + String( i ) + 'AcDc', parseInt( acdc, 10 ) );
      hfTables.set( 'Table' + String( i ) + 'ID', parseInt( id, 10 ) );

      let hfTableCounters = _.array.makeArrayOfLengthZeroed( 16 );
      for( let i = 0; i < 16; i++ )
      {
        hfTableCounters[ i ] = hfTableArray[ i + 1 ];  // Make Counters array
      }

      // Get Huffman Values
      let v = 0;           // value counter
      let h = new Map();   //Huffman Table

      for( let i = 0; i < 16; i++ )
      {
        let values = _.array.makeArrayOfLengthZeroed( hfTableCounters[ i ] );

        for( let j = 0; j < values.length; j ++ )
        {
          values[ j ] = hfTableArray[ 17 + v ];
          v = v + 1;
        }
        h.set( 'l' + String( i + 1 ), values );
      }

      binaryTree( h );

      let hfTableCodes = _.array.makeArrayOfLengthZeroed( v );
      let hfTableValues = _.array.makeArrayOfLengthZeroed( v );
      let s = 0;
      for( let j = 0; j < 16; j++ )
      {
        let valueArray = h.get( 'l' + String( j + 1 ) );
        if( h.get( 'l' + String( j + 1 ) ).length !== 0 )
        {
          let codeArray = h.get( 'lb' + String( j + 1 ) );
          for( let f = 0; f < valueArray.length; f++ )
          {
            hfTableValues[ s ] = valueArray[ f ];
            hfTableCodes[ s ] = codeArray[ f ];
            s = s + 1;
          }

        }
      }
      hfTables.set( 'Table' + String( i ) + 'Codes', hfTableCodes );
      hfTables.set( 'Table' + String( i ) + 'Values', hfTableValues );
    }

    // Make binary Tree
    function binaryTree( hT )
    {
      let bin = '';  // binary string
      let start = 0;
      for( let i = 0; i < 16; i++ )
      {
        if( hT.get( 'l'+String( i + 1 )).length === 0 )
        {
          bin = bin + '0';
          if( start !== 0 )
          {
            bin = increaseBinary( bin );
          }
        }
        else
        {
          let values = _.array.makeArrayOfLengthZeroed( hT.get( 'l'+String( i + 1 )).length );

          if( start === 0 )
          {
            bin = '0' + bin;
            start = 1;
            values[ 0 ] = bin;

            for( let j = 1; j < values.length; j++ )
            {
              bin = increaseBinary( bin );
              values[ j ] = bin ;
            }
          }
          else
          {
            for( let j = 0; j < values.length; j++ )
            {
              bin = increaseBinary( bin );

              if( j === 0 )
              {
                bin = bin + '0';
              }
              values[ j ] = bin ;
            }
          }
          hT.set( 'lb' + String( i + 1 ), values );
        }
      }
    }
  }

  getHuffmanTables( dataViewByte, hfTables );

  //GET SCAN DATA :

  logger.log('')
  logger.log('START OF SCAN')

  // Number of blocks
  let numOfBlocks = Math.ceil( imageHeight / (8 * hMax ) ) * Math.ceil( imageWidth / ( 8 * vMax ) );

  // Get Scan data bytes
  let length = 2 + image[ 2 ]*256 + image[ 3 ];
  let imageString = '';

  for( let i = length; i < imageB.length; i++ )
  {
    while( imageB[ i ].length < 8 )
    {
      imageB[ i ] = '0' + imageB[ i ];
    }

    _.assert( imageB[ i ].length === 8 );
    imageString = imageString + imageB[ i ].toString();
  }

  // MAKE IMAGE DIVISIBLE BY 8:

  let oneBlock = false;
  if( imageHeight === 8 && imageWidth === 8 )
  oneBlock = true;

  let rH = imageHeight % ( 8 * vMax );
  let rW = imageWidth % ( 8 * hMax );

  while( rH !== 0 )
  {
    imageHeight = imageHeight + 1;
    rH = imageHeight % ( 8 * vMax );
  }

  while( rW !== 0 )
  {
    imageWidth = imageWidth + 1;
    rW = imageWidth % ( 8 * hMax );
  }

  if( oneBlock === true )
  {
    var imageValues = new Uint8Array( 4 * 8 * 8 );
  }
  else
  {
    var imageValues = new Uint8Array( 4 * imageHeight * imageWidth );
  }

  // LOOP OVER ALL THE IMAGE

  let index = 0;
  let oldDValues = new Map();
  let finalComps = new Map();
  let hNumOfBlocks = imageWidth / ( 8 * hMax );
  let vNumOfBlocks = imageHeight / ( 8 * vMax );

  for ( let c = 0; c < numOfComponents; c++ )
  {
    oldDValues.set( ( 'C' + _.str( c + 1 ) ).substring( 0, 2 ), 0 );
  }

//  for( let b = 0; b < 1; b++ )  // one blocks
  for( let bv = 0; bv < vNumOfBlocks; bv++ )  // loop through vertical blocks
  {
    for( let bh = 0; bh < hNumOfBlocks; bh++ )  // loop through horizontal blocks
    {
      index = decodeHuffman( components, frameData, hfTables, imageString, index );

      // Increase DC term
      for ( let [ key, value ] of components )
      {
        if( typeof( value ) === 'object')
        {
          //logger.log( 'KEY', key, 'DC', value[ 0 ] )
          Array.from( value );
          value[ 0 ] = value[ 0 ] + oldDValues.get( key.substring( 0, 2 ) );
          oldDValues.set( key.substring( 0, 2 ), value[ 0 ] );
        }
      }

      dequantizeVector( components, frameData, qTables );

      zigzagOrder( components );

      for ( let [ key, value ] of components )
      {
        if( typeof( value ) === 'object')
        {
          let s = iDCT( value );
          components.set( key, s );
        }
      }

      setSameSize( components, frameData, finalComps );

      ycbcrToRGB( finalComps );

      let xMax = _.Space.dimsOf( finalComps.get( 'R' ) )[ 0 ];
      let yMax = _.Space.dimsOf( finalComps.get( 'R' ) )[ 1 ];

      // FILL IMAGE DATA ARRAY
      if( oneBlock  === false )
      {
        let imageIndex = bv * xMax * yMax * hNumOfBlocks * 4 + bh * xMax * 4;
        for( let x = 0; x < xMax; x++ )
        {
          for( let y = 0; y < yMax; y++ )
          {
            imageValues[ imageIndex ] = finalComps.get( 'R' ).atomGet( [ x, y ] );
            imageIndex = imageIndex + 1;
            imageValues[ imageIndex ] = finalComps.get( 'G' ).atomGet( [ x, y ] );
            imageIndex = imageIndex + 1;
            imageValues[ imageIndex ] = finalComps.get( 'B' ).atomGet( [ x, y ] );
            imageIndex = imageIndex + 1;
            imageValues[ imageIndex ] = 255;
            imageIndex = imageIndex + 1;
            _.assert( imageIndex <= imageValues.length, imageIndex );
          }
          imageIndex = imageIndex + 4 * yMax * ( hNumOfBlocks - 1 );
        }
      }
      else
      {
        let imageIndex = 0;
        for( let x = 0; x < 8; x++ )
        {
          for( let y = 0; y < 8; y++ )
          {
            imageValues[ imageIndex ] = finalComps.get( 'R' ).atomGet( [ x, y ] );
            imageIndex = imageIndex + 1;
            imageValues[ imageIndex ] = finalComps.get( 'G' ).atomGet( [ x, y ] );
            imageIndex = imageIndex + 1;
            imageValues[ imageIndex ] = finalComps.get( 'B' ).atomGet( [ x, y ] );
            imageIndex = imageIndex + 1;
            imageValues[ imageIndex ] = 255;
            imageIndex = imageIndex + 1;
            _.assert( imageIndex <= imageValues.length, imageIndex );
          }
        }
      }


      /*
      logger.log('RESULT')
      for ( let [ key, value ] of finalComps )
      {
        logger.log( key, value )
        logger.log( '')
        if( typeof( value ) === 'object')
        {

        }
      }
      */

    }
  }
  return imageValues;

}

// --
// relations
// --


let Extend =
{
  getData : getData,

  byteToHex : byteToHex,
  binaryToByte : binaryToByte,
  increaseBinary : increaseBinary,

  decodeHuffman : decodeHuffman,
  dequantizeVector : dequantizeVector,
  zigzagOrder : zigzagOrder,
  iDCT : iDCT,
  setSameSize : setSameSize,
  ycbcrToRGB : ycbcrToRGB,

  decodeJPG : decodeJPG,

}

_.classExtend( Self, Extend );

})();
