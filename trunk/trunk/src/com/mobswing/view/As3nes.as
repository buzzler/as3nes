package com.mobswing.view
{
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.System;

	/**
	 * vNES.java
	 */
	public class As3nes extends MovieClip
	{
		private var rom				:String;
		private var scale			:Boolean;
		private var sound			:Boolean;
		private var stereo			:Boolean;
		private var scanlines		:Boolean;
		private var fps				:Boolean;
		private var nicesound		:Boolean;
		private var timeemulation	:Boolean;
		private var showsoundbuffer	:Boolean;
		private var romSize			:int;
		
		public function As3nes()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		
		private	function onAdded():void
		{
			readParam();
			System.gc();
		}
		
		private function onRemoved():void
		{
			;
		}

		private	function readParam():void
		{
			var tmp:String;
			var info:LoaderInfo = this.loaderInfo;
			
			tmp = info.parameters['rom'] as String;
			if (tmp == null || tmp == '')
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
				this.romSize = 24952;
			else
				this.romSize = int(parseInt(tmp));
		}	
	}
}