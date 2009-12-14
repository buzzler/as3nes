package com.mobswing.model
{
	public class CPU
	{
		public function CPU(nes:Nes)
		{
		}
		
		public	function init():void
		{
			;
		}
		
		public	function destroy():void
		{
			;
		}
		
		public	function reset():void
		{
			;
		}
		
		public	function setMapper(mapper:IMemoryMapper):void
		{
			;
		}
		
		public	function stateLoad(buf:ByteBuffer):void
		{
			;
		}
		
		public	function stateSave(buf:ByteBuffer):void
		{
			;
		}
		
		public	function beginExcution():void
		{
			;
		}
		
		public	function endExcution():void
		{
			;
		}

		public	function isRunning():Boolean
		{
			return true;
		}
	}
}