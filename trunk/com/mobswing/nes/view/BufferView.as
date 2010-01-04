package com.mobswing.view
{
	import __AS3__.vec.Vector;
	
	import com.mobswing.model.Globals;
	import com.mobswing.model.Nes;
	
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
	public class BufferView extends ASPanel
	{
		protected var nes:Nes;
		
		private var _width		:int;
		private var _height		:int;
		private var pix			:Vector.<uint>;

		//FPS counter variables
		private var		prevFrameTime	:Number = 0;
		public	var		FPS				:Number = 0;
		
		public function BufferView(nes:Nes, width:int, height:int)
		{
			super();
			this.nes = nes;
			this._width = width;
			this._height = height;
		}

		public	function init():void
		{
			createView();
		}
		
		private function createView():void
		{
			this.bitmapData = new BitmapData(this._width, this._height, false, Globals.bgColor);
			
			var raster:Vector.<uint> = bitmapData.getVector(bitmapData.rect);
			this.pix = raster;
			this.nes.getPpu().buffer = raster;
		}

		public	function imageReady(skipFrame:Boolean):void
		{
			if (!skipFrame)
			{
				this.nes.getPpu().requestRenderAll = false;

				this.bitmapData.lock();
				this.bitmapData.setVector(this.bitmapData.rect, pix);
				this.bitmapData.unlock();
				
				var t:int = getTimer();
				FPS = 1000 / (t - prevFrameTime);
				prevFrameTime = t;
			}
		}

		public	function destroy():void
		{
			this.nes = null
			this.removeAllKeyListener();
		}
	}
}