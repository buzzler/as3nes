package com.mobswing.control
{
	import flash.utils.ByteArray;
	
	public class Crc32
	{
		public function Crc32()
		{
		}

		public	static function encode(source:ByteArray):Number
		{
		    var a:Number;
		    var b:Number;
		    var c:Number;
		    var d:Number = -1;
		            
		    var i:Number = -1;
		    var n:Number = source.length;
		            
		    while( ++ i < n )
		    {
		        a = source[ i ];
		        b = ( d ^ a ) & 255;
		        c = table[ b ]
		        d = ( d >>> 8 ) ^ c;
		    }
		        
		    return ( d ^ -1 );
		}
	}
}