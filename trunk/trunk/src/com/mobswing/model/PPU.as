
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