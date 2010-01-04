package com.mobswing.model
{
	public class Globals
	{
		public	static const CPU_FREQ_NTSC		:Number	= 1789772.5;
		public	static const CPU_FREQ_PAL		:Number	= 1773447.4;
		
		public	static const WIDTH				:int	= 256;
		public	static const HEIGHT				:int	= 240;
		
		public	static var bgColor				:uint	= 0x000000;
		
		public	static var preferredFrameRate	:int	= 60;
		public	static var frameTime			:int	= 1000 / preferredFrameRate;
		public	static var memoryFlushValue		:int	= 0xFF;
		
		public	static var disableSprites		:Boolean= false;
		public	static var timeEmulation		:Boolean= true;
		public	static var palEmulation			:Boolean= false;
		public	static var enableSound			:Boolean= false;
		public	static var stereoSound			:Boolean= true;
		public	static var volume				:Number	= 1;

		public function Globals()
		{
		}
	}
}