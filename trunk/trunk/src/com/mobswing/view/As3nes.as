package com.mobswing.view
{
	import com.mobswing.control.FilePreloader;
	import com.mobswing.control.SwfUI;
	import com.mobswing.model.Globals;
	import com.mobswing.model.Nes;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class As3nes extends ASPanel
	{
		private var scale			:Boolean;
		private var sound			:Boolean;
		private var stereo			:Boolean;
		private var scanlines		:Boolean;
		private var fps				:Boolean;
		private var nicesound		:Boolean;
		private var timeemulation	:Boolean;
		private var showsoundbuffer	:Boolean;
		private var samplerate		:int;
		public	var romSize			:int;
		private var progress		:int;
		
		private var gui				:SwfUI;
		private var nes				:Nes;
		private var panelScreen		:ScreenView;
		private var rom				:String;
		private var progressFont	:TextField;
		public	var bgColor			:int	= 0x000000;
		private var started			:Boolean;
		
		public function As3nes()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private	function onAdded(event:Event = null):void
		{
			readParam();
			System.gc();
			
			var loader:FilePreloader = FilePreloader.getInstance();
			loader.reserve('palettes/ntsc.txt', URLLoaderDataFormat.TEXT, 'ntsc');
			loader.reserve('palettes/pal.txt', URLLoaderDataFormat.TEXT, 'pal');
			loader.reserve(this.rom, URLLoaderDataFormat.BINARY, 'rom');
			loader.addEventListener(Event.COMPLETE, onLoaded);
			loader.load();
		}
		
		private function onLoaded(event:Event):void
		{
			var loader:FilePreloader = event.target as FilePreloader;
			loader.removeEventListener(Event.COMPLETE, onLoaded);
			
			this.gui = new SwfUI(this);
			this.gui.init(false);
			
			Globals.movieclipMode = true;
			Globals.memoryFlushValue = 0;
			
			this.nes = this.gui.getNes();
			this.nes.enableSound(this.sound);
			this.nes.reset();
			
			this.startEmulation();
		}
		
		public	function addScreenView():void
		{
			this.panelScreen = this.gui.getScreenView() as ScreenView;
			this.panelScreen.setFPSEnabled(this.fps);
			
			//Layout Manager setting skipped
			
			if (this.scale)
			{
				if (this.scanlines)
					this.panelScreen.setScaleMode(BufferView.SCALE_SCANLINE);
				else
					this.panelScreen.setScaleMode(BufferView.SCALE_NORMAL);

				this.setSize(512, 480);
				this.setBounds(0,0,512,480);
				this.panelScreen.setBounds(0,0,512,480);
			}
			else
			{
				this.panelScreen.setBounds(0,0,256,240);
			}
			
			//Ignore repaint operation skipped
			this.addChild(this.panelScreen);
		}
		
		public	function startEmulation():void
		{
			var format:TextFormat = new TextFormat('Times New Roman', 12, 0xDDDDDD);
			this.progressFont = new TextField();
			this.progressFont.setTextFormat(format);
			
			this.started = true;
			
			trace("AS3NES \u00A9 2009 Shim KyungHyun");
			trace("Use of this program subject to GNU GPL, Version 3.");
			
			this.nes.loadRom(this.rom);
			if (this.nes.getRom().isValid())
			{
				addScreenView();
				
				Globals.timeEmulation = this.timeemulation;
				this.nes.getPpu().showSoundBuffer = this.showsoundbuffer;
				
				this.nes.getCpu().beginExcution();
			}
			else
			{
				trace("AS3NES was unable to find ("+rom+").");
			}
		}
		
		public	function stopEmulation():void
		{
			this.nes.stopEmulation();
			this.nes.getPapu().stop();
			this.destroy();
		}
		
		private function destroy():void
		{
			if (this.nes != null && this.nes.getCpu().isRunning())
			{
				stopEmulation();
			}
			if (this.nes != null) this.nes.destroy();
			if (this.gui != null) this.gui.destroy();
			
			this.gui = null;
			this.nes = null;
			this.panelScreen = null;
			this.rom = null;
			
			System.exit(0);
			System.gc();
		}
		
		public	function showLoadProgress(percentComplete:int):void
		{
			this.progress = percentComplete;
			paint(this.graphics);
		}
		
		public	function paint(g:Graphics):void
		{
			var disp:String;
			var scrw:int, scrh:int;
			var txtw:int, txth:int;
			
			if (!this.started) return;
			
			if (this.scale)
			{
				scrw = 512;
				scrh = 480;
			}
			else
			{
				scrw = 256;
				scrh = 240;
			}
			
			//fill background
			g.beginFill(this.bgColor);
			g.drawRect(0,0,scrw, scrh);
			g.endFill();
			
			//Progress text
			disp = "AS3NES is Loading Game... "+progress.toString()+"%";
			this.progressFont.autoSize	= TextFieldAutoSize.LEFT;
			this.progressFont.text		= disp;
			txtw = this.progressFont.width;
			txth = this.progressFont.height;
			
			var bmp:BitmapData = new BitmapData(txtw,txth,true,0x00000000);
			bmp.draw(this.progressFont);
			g.beginBitmapFill(bmp);
			g.drawRect(scrw/2-txth/2,scrh/2-txth/2,txtw,txth);
			g.endFill();
			bmp.dispose();
		}
		
		public	function update(g:Graphics):void
		{
			//do nothing
		}

		private	function readParam():void
		{
			var tmp:String;
			var info:LoaderInfo = this.loaderInfo;
			
			tmp = info.parameters['rom'] as String;
			if (tmp == null || tmp == '')
				//this.rom = "roms/Kirby's Adventure.nes";
				//this.rom = "roms/NES Test Cart.nes";
				this.rom = "roms/Mario Bros.nes";
			else
				this.rom = tmp;

			tmp = info.parameters['scale'] as String;
			if (tmp == null || tmp == '')
				this.scale = false;
			else
				this.scale = (tmp == 'on');

			tmp = info.parameters['sound'] as String;
			if (tmp == null || tmp == '')
				this.sound = true;
			else
				this.sound = (tmp == 'on');
			
			tmp = info.parameters['stereo'] as String;
			if (tmp == null || tmp == '')
				this.stereo = true;
			else
				this.stereo = (tmp == 'on');

			tmp = info.parameters['scanlines'] as String;
			if (tmp == null || tmp == '')
				this.scanlines = true;
			else
				this.scanlines = (tmp == 'on');

			tmp = info.parameters['fps'] as String;
			if (tmp == null || tmp == '')
				this.fps = true;
			else
				this.fps = (tmp == 'on');

			tmp = info.parameters['nicesound'] as String;
			if (tmp == null || tmp == '')
				this.nicesound = true;
			else
				this.nicesound = (tmp == 'on');

			tmp = info.parameters['timeemulation'] as String;
			if (tmp == null || tmp == '')
				this.timeemulation = true;
			else
				this.timeemulation = (tmp == 'on');

			tmp = info.parameters['showsoundbuffer'] as String;
			if (tmp == null || tmp == '')
				this.showsoundbuffer = true;
			else
				this.showsoundbuffer = (tmp == 'on');

			tmp = info.parameters['romsize'] as String;
			if (tmp == null || tmp == '')
				//this.romSize = 786448;
				//this.romSize = 40976;
				this.romSize = 24952;
			else
				this.romSize = int(parseInt(tmp));
		}	
	}
}