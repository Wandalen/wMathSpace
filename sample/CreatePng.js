if( typeof module !== 'undefined' )
require( 'wTools' );
require( 'wmathspace' );
require('wFiles');
var _ = wTools;


// Include the path of a jpg file
let jpgPath = 'C:/Users/pabel/Desktop/Trabajo/Kos/JPEGdecoder/Images/lions.jpg'
let s = _.Space.make([ 3, 3 ]);
let jpgValues = s2.getData( jpgPath );
let imValues = s.decodeJPG( jpgValues );

var fs = require('fs'),
    PNG = require('pngjs').PNG;

/* Include the expanded dimensions of the image ( must be divisible by 16 )
* Example: lion.jpg dims = 269, 187
* new dims = 272, 192  where 272 / 16 = 17 & 192 / 16 = 12
*/
var png = new PNG({
    width: 272,
    height: 192,
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
png.pack().pipe(fs.createWriteStream('Images/lionsDecoded.png'));
