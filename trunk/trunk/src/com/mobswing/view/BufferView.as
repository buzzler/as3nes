package com.mobswing.view
{
	import __AS3__.vec.Vector;
	
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

		public	function imageReady(skipFrame:Boolean):void
		{
			;
		}
		
		public	function getImage():BitmapData
		{
			return this.img;
		}
		
		public	function getBuffer():Vector.<int>
		{
			return this.pix;
		}
		
		public	function update(g:Graphics):void
		{
			;
		}
		
		public	function scalingEnabled():Boolean
		{
			return scaleMode!=SCALE_NONE;
		}

		public	function getScaleMode():int
		{
			return this.scaleMode;
		}
		
		public	function useNormalScaling():Boolean
		{
			return (this.scaleMode == SCALE_NORMAL);
		}
		
		public	function paint(g:Graphics):void
		{
			;
		}
		
		public	function paint_scaled(g:Graphics):void
		{
			;
		}

		public	function setFPSEnabled(value:Boolean):void
		{
			this.showFPS = value;
		}
		
		public	function paintFPS(x:int, y:int, g:Graphics):void
		{
			;
		}
		
		public	function getBufferWidth():int
		{
			return this._width;
		}
		
		public	function getBufferHeight():int
		{
			return this._height;
		}
		
		public	function setUsingMenu(val:Boolean):void
		{
			this.usingMenu = val;
		}
		
		public	function useHWScaling(mode:int = -1):Boolean
		{
			if (mode == -1) mode = this.scaleMode;
			return mode==SCALE_HW2X || mode==SCALE_HW3X;
		}
		
		public	function getScaleModeScale(mode:int):int
		{
			switch (mode)
			{
			case -1:
				return -1;
			case SCALE_NONE:
				return 1;
			case SCALE_HW3X:
				return 3;
			default:
				return 2;
			}
		}
		
		public	function destroy():void
		{
			this.nes = null
			this.img = null;
		}
	}
}