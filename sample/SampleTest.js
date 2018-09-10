
if( typeof module !== 'undefined' )
require( 'wmathspace' );
require('wFiles');


var _ = wTools;

// Manipulates local drive
var provider = _.FileProvider.HardDrive();

// Manipulates file on filesTree
/*
var tree =
{
 "‪C:/Users/pabel/Pictures/" :
 {
   'TEST.txt' : "content",
   'empty_dir' : {}
 }
}

var provider = _.FileProvider.Extract({ filesTree : tree });
*/

/*Read file synchronously*/
debugger;
var data = provider.fileRead
({
  pathFile : '‪C:/Users/pabel/Pictures/TEST.txt',
  sync : 1
});

  debugger;
console.log( data );
