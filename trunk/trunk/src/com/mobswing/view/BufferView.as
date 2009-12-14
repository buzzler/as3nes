package com.mobswing.view
{
	import com.mobswing.model.Nes;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.text.TextField;
	
	public class BufferView extends ASPanel
	{
		public static const SCALE_NONE:int		= 0;
		public static const SCALE_HW2X:int		= 1;
		public static const SCALE_HW3X:int		= 2;
		public static const SCALE_NORMAL:int	= 3;
		public static const SCALE_SCANLINE:int	= 4;
		public static const SCALE_RASTER:int	= 5;

		protected var nes:Nes;
		
		private var img:BitmapData;
		private var vimg:BitmapData;
		private var usingMenu:Boolean = false;
		
		private var gfx:Graphics;
		private var _width:int;
		private var _height:int;
		private var pix:Vector.<int>;
		private var pix_scaled:Vector.<int>;
		private var scaleMode:int;

		//FPS counter variables
		private var showFPS:Boolean = false;
		private var prevFrameTime:Number;
		private var fps:String;
		private var fpsCount:int;
		private var fpsFont:TextField;
		private var bgColor:uint = 0xEEEEEE;

		public function BufferView(nes:Nes, width:int, height:int)
		{
			super();
			this.nes = nes;
			this._width = width;
			this._height = height;
			this.scaleMode = -1;
			
			//appended by buzzler
			this.setSize(width, height);
		}

		public	function setBgColor(color:uint):void
		{
			this.bgColor = color;
		}

		public	function setScaleMode(newMode:int):void
		{
			if (newMode != this.scaleMode)
			{
				var diffHW:Boolean = useHWScaling(newMode) != useHWScaling(this.scaleMode);
				var diffSz:Boolean = getScaleModeScale(newMode) != getScaleModeScale(this.scaleMode);
				
				this.scaleMode = newMode;
				
				if (diffHW || diffSz)
					createView();
			}
		}
		
		public	function init():void
		{
			setScaleMode(SCALE_NONE);
		}
		
		private function createView():void
		{
			var scale:int = getScaleModeScale(this.scaleMode);
			
			if (!useHWScaling(this.scaleMode))
			{
				;
			}
			else
			{
				;
			}
			
			
		}

		public	function setFPSEnabled(value:Boolean):void
		{
			;
		}
		
		public	function useHWScaling(mode:int):Boolean
		{
			return false;
		}
		
		public	function getScaleModeScale(mode:int):int
		{
			return 0;
		}
		
		public	function destroy():void
		{
			;
		}
	}
}