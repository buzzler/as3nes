package com.mobswing.model
{
	public class ROM
	{
		public function ROM(nes:Nes)
		{
		}

		public	function load(filename:String):void
		{
			;
		}

		public	function isValid():Boolean
		{
			return true;
		}
		
		public	function createMapper():IMemoryMapper
		{
			return null;
		}
		
		public	function getMirroringType():int
		{
			return 0;
		}
		
		public	function closeRom():void
		{
			;
		}
		
		public	function destroy():void
		{
			;
		}
	}
}