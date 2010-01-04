package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class NameTable
	{
		private var name:String;
		
		private var tile:Vector.<int>;
		private var attrib:Vector.<int>;
		
		private var width:int;
		private var height:int;

		public	function NameTable(width:int, height:int, name:String)
		{
			this.name = name;
			this.width = width;
			this.height = height;
			
			tile = new Vector.<int>(width*height);
			attrib = new Vector.<int>(width*height);
		}


		public	function getTileIndex(x:int, y:int):int
		{
			return tile[y*width+x];
		}
		
		public	function getAttrib(x:int, y:int):int
		{
			return attrib[y*width+x];
		}
		
		public	function writeTileIndex(index:int, value:int):void
		{
			tile[index] = value;
		}

		public	function writeAttrib(index:int, value:int):void
		{
			var basex:int, basey:int;
			var add:int;
			var tx:int, ty:int;
			var attindex:int;
			basex = index%8;
			basey = index/8;
			basex *= 4;
			basey *= 4;
			
			for (var sqy:int = 0 ; sqy < 2 ; sqy++)
			{
				for (var sqx:int = 0 ; sqx < 2 ; sqx++)
				{
					add = (value>>(2*(sqy*2+sqx)))&3;
					for (var y:int = 0 ; y < 2 ; y++)
					{
						for (var x:int = 0 ; x < 2 ; x++)
						{
							tx = basex+sqx*2+x;
							ty = basey+sqy*2+y;
							attindex = ty*width+tx;
							attrib[ty*width+tx] = ((add<<2)&12);
						}
					}
				}
			}
		}
		
		public	function stateSave(buf:ByteBuffer):void
		{
			var i:int;
			for (i = 0 ; i < width*height ; i++)
			{
				if (tile[i] > 255)
					buf.putByte(tile[i] & 255);
			}
			for (i = 0 ; i < width*height ; i++)
			{
				buf.putByte(attrib[i] & 255);
			}
		}
		
		public	function stateLoad(buf:ByteBuffer):void
		{
			var i:int;
			for(i = 0 ; i < width*height ; i++)
			{
				tile[i] = buf.readByte();
			}
			for (i = 0 ; i < width*height ; i++)
			{
				attrib[i] = buf.readByte();
			}
		}
	}
}