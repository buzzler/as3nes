package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	public class ByteBuffer
	{
		public function ByteBuffer()
		{
		}

		public	function putByte(value:int):Boolean
		{
			return true;
		}

		public	function readByte():int
		{
			return 0;
		}
		
		public	function readByteArray(arr:Vector.<int>):Boolean
		{
			return false;
		}
		
		public	function putInt(value:int):void
		{
			;
		}
		
		public	function readInt():int
		{
			return 0;
		}
	}
}