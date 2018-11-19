if( typeof module !== 'undefined' )
require( 'wTools' );
require( 'wmathspace' );
require('wFiles');
var path = require('path');

var _ = wTools;


// Include the path of a jpg file
let jpgPath =  __dirname + '/../assets/Images/JPG/lions.jpg';
var correctedPath = path.normalize(jpgPath);
console.log(correctedPath);

// Decode Image
let s = _.Space.make([ 3, 3 ]);
let jpgValues = s.getData( correctedPath );
debugger;
let imValues = s.decodeJPG( jpgValues );

logger.log( 'Decoded from', jpgValues.length, 'jpg values to', 0.75 * imValues.length, 'rgb values.')

// Create PNG
var fs = require('fs'),
    PNG = require('pngjs').PNG;

/* Include the dimensions of the image
* Example: lion.jpg dims = 269, 187
*/
var png = new PNG({
    width: 269,
    height: 187,
    filterType: -1
});

let i = 0;
for (var y = 0; y < png.height; y++) {
    for (var x = 0; x < png.width; x++) {
        var idx = (png.width * y + x) << 2;
        png.data[ idx ] = imValues[ i ];
        png.data[ idx+1 ] = imValues[ i + 1 ];
        png.data[ idx+2 ] = imValues[ i + 2 ];
        png.data[ idx+3 ] = imValues[ i + 3 ];
        i = i + 4;
    }
}

// Include a name for the new png file
png.pack().pipe(fs.createWriteStream('assets/Images/PNG/lionsDecoded.png'));
