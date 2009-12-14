package com.mobswing.view
{
	import flash.display.Sprite;
	
	public class BufferView extends ASPanel
	{
		public static const SCALE_NONE:int		= 0;
		public static const SCALE_HW2X:int		= 1;
		public static const SCALE_HW3X:int		= 2;
		public static const SCALE_NORMAL:int	= 3;
		public static const SCALE_SCANLINE:int	= 4;
		public static const SCALE_RASTER:int	= 5;
			
		public function BufferView()
		{
		}

		public	function setScaleMode(newMode:int):void
		{
			;
		}

		public	function setFPSEnabled(value:Boolean):void
		{
			;
		}
		
		public	function setBgColor(color:uint):void
		{
			;
		}
		
		public	function destroy():void
		{
			;
		}
	}
}