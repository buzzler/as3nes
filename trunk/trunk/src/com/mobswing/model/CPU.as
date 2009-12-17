package com.mobswing.model
{
	public class CPU
	{
		public static const IRQ_NORMAL:int = 0;
		public static const IRQ_NMI:int    = 1;
		public static const IRQ_RESET:int  = 2;
		
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
		
		public	function requestIrq(type:int):void
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