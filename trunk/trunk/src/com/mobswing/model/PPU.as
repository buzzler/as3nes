
package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	public class PPU
	{
		public	var ptTile:Vector.<Tile>;
		public	var showSoundBuffer:Boolean = false;
		public	var buffer:Vector.<uint>;
		public	var requestRenderAll:Boolean = false;
		public	var scanlineChanged:Vector.<Boolean> = new Vector.<Boolean>(240);
		
		public function PPU(nes:Nes)
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
		
		public	function sramLoad():int
		{
			return 0;
		}
		
		public	function vramLoad():int
		{
			return 0;
		}
		
		public	function readStatusRegister():int
		{
			return 0;
		}
		
		public	function writeSRAMAddress(address:int):void
		{
			;
		}
		
		public	function writeVRAMAddress(address:int):void
		{
			;
		}
		
		public	function vramWrite(value:int):void
		{
			;
		}
		
		public	function sramDMA(value:int):void
		{
			;
		}
		
		public	function sramWrite(value:int):void
		{
			;
		}
		
		public	function scrollWrite(value:int):void
		{
			;
		}
		
		public	function updateControlReg1(value:int):void
		{
			;
		}
		
		public	function updateControlReg2(value:int):void
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
		
		public	function setMirroring(mirroring:int):void
		{
			;
		}
		
		public	function triggerRendering():void
		{
			;
		}
	}
}