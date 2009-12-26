package com.mobswing.model
{
	public class PAPU
	{
		public	var bufferIndex:int;
		public	var line:ISourceDataLine;

		public function PAPU(nes:Nes)
		{
		}

		public	function start():void
		{
			;
		}

		public	function stop():void
		{
			;
		}
		
		public	function destroy():void
		{
			;
		}

		public	function getLine():ISourceDataLine
		{
			return null;
		}

		public	function clockFrameCounter(nCycles:int):void
		{
			;
		}

		public	function readReg(address:int):int
		{
			return 0;
		}
		
		public	function writeReg(address:int, value:int):void
		{
			value &= 65535;
		}
		
		public	function getMillisToAvailableAbove(target_avail:int):int
		{
			return 0;
		}
		
		public	function writeBuffer():void
		{
			;
		}
		
		public	function isRunning():Boolean
		{
			return false;
		}
		
		public	function reset():void
		{
			;
		}
		
		public	function getSampleRate():int
		{
			return 1;
		}
		
		public	function setSampleRate(rate:int,restart:Boolean):void
		{
			;
		}
	}
}