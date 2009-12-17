package com.mobswing.view
{
	import com.mobswing.control.Scale;
	import com.mobswing.model.Nes;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class BufferView extends ASPanel
	{
		public static const SCALE_NONE:int		= 0;
		public static const SCALE_HW2X:int		= 1;
		public static const SCALE_HW3X:int		= 2;
		public static const SCALE_NORMAL:int	= 3;
		public static const SCALE_SCANLINE:int	= 4;
		public static const SCALE_RASTER:int	= 5;

		protected var nes:Nes;
		
		private var img			:BitmapData;
		private var vimg		:BitmapData;
		private var usingMenu	:Boolean = false;
		
		private var gfx			:Graphics;
		private var _width		:int;
		private var _height		:int;
		private var pix			:Vector.<uint>;
		private var pix_scaled	:Vector.<uint>;
		private var scaleMode	:int;

		//FPS counter variables
		private var showFPS		:Boolean = false;
		private var prevFrameTime:Number;
		private var fps			:String;
		private var fpsCount	:int;
		private var fpsFont		:TextField;
		private var bgColor		:uint = 0xEEEEEE;
		
		private static const mat_2x		:Matrix = new Matrix(2,0,0,2,0,0);
		private static const mat_3x		:Matrix = new Matrix(3,0,0,3,0,0);

		public function BufferView(nes:Nes, width:int, height:int)
		{
			super();
			this.nes = nes;
			this._width = width;
			this._height = height;
			this.scaleMode = -1;
			
			//appended by buzzler
			this.fpsFont = new TextField();
			this.fpsFont.autoSize = TextFieldAutoSize.LEFT;
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
				img = new BitmapData(this._width*scale, this._height*scale);
			}
			else
			{
				img = new BitmapData(this._width, this._height);
				vimg = new BitmapData(this._width, this._height);
			}
			
			var raster:Vector.<uint> = img.getVector(img.rect);
			switch (this.scaleMode)
			{
			case SCALE_NONE:
			case SCALE_HW2X:
			case SCALE_HW3X:
				this.pix = raster;
				this.nes.getPpu().buffer = raster;
				break;
			default:
				this.pix_scaled = raster;
				break;
			}
			
			for (var i:int = 0 ; i < raster.length ; i ++)
			{
				raster[i] = this.bgColor;
			}
			setSize(this._width*scale, this._height*scale);
			setBounds(0, 0, this._width*scale, this._height*scale);
			
			//invalidate
			//repaint
		}

		public	function imageReady(skipFrame:Boolean):void
		{
			if (skipFrame)
			{
				switch (this.scaleMode)
				{
				case SCALE_NORMAL:
					Scale.doNormalScaling(this.pix, this.pix_scaled, this.nes.getPpu().scanlineChanged);
					break;
				case SCALE_SCANLINE:
					Scale.doScanlineScaling(this.pix, this.pix_scaled, this.nes.getPpu().scanlineChanged);
					break;
				case SCALE_RASTER:
					Scale.doRasterScaling(this.pix, this.pix_scaled, this.nes.getPpu().scanlineChanged);
					break;
				default:
					break;
				}
				
				this.nes.getPpu().requestRenderAll = false;
				paint(this.graphics);
			}
		}
		
		public	function getImage():BitmapData
		{
			return this.img;
		}
		
		public	function getBuffer():Vector.<uint>
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
			if (this.usingMenu) return;
			
			if (this.scaleMode != SCALE_NONE)
			{
				paintFPS(0, 14, g);
				paint_scaled(g);
			}
			else if (this.img != null && g != null)
			{
				paintFPS(0, 14, g);
				g.beginBitmapFill(this.img);
				g.drawRect(0,0,this.img.width, this.img.height);
				g.endFill();
			}
		}
		
		public	function paint_scaled(g:Graphics):void
		{
			if (this.usingMenu) return;
			
			if (this.scaleMode == SCALE_HW2X)
			{
				if (g != null && this.img != null && this.vimg != null)
				{
					this.vimg.draw(this.img);
					g.beginBitmapFill(this.vimg, BufferView.mat_2x);
					g.drawRect(0,0,this._width*2, this._height*2);
					g.endFill();
				}
			}
			else if (this.scaleMode == SCALE_HW3X)
			{
				if (g != null && this.img != null && this.vimg != null)
				{
					this.vimg.draw(this.img);
					g.beginBitmapFill(this.vimg, BufferView.mat_3x);
					g.drawRect(0,0,this._width*3, this._height*3);
					g.endFill();
				}
			}
			else
			{
				if (g != null && this.img != null)
				{
					g.beginBitmapFill(this.img, BufferView.mat_2x);
					g.drawRect(0,0,this._width*2,this._height*2);
					g.endFill();
				}
			}
		}

		public	function setFPSEnabled(value:Boolean):void
		{
			this.showFPS = value;
		}
		
		public	function paintFPS(x:int, y:int, g:Graphics):void
		{
			if (this.usingMenu) return;
			
			if (this.showFPS)
			{
				if (--this.fpsCount <= 0)
				{
					var ct:Number = this.nes.getGui().getTimer().currentMicros();
					var frameT:Number = (ct - this.prevFrameTime) / 45;
					if (frameT == 0)
						this.fps = "FPS: -";
					else
						this.fps = "FPS: " + (1000000 / frameT).toString();
					this.fpsCount = 45;
					this.prevFrameTime = ct;
					this.fpsFont.text = this.fps;
				}
				
				var bmp:BitmapData = new BitmapData(this.fpsFont.width, this.fpsFont.height, true, 0x00000000);
				bmp.draw(this.fpsFont);
				g.beginBitmapFill(bmp);
				g.drawRect(x,y, bmp.width, bmp.height);
				g.endFill();
			}
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