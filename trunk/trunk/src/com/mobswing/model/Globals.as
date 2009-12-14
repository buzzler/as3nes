package com.mobswing.model
{
	public class Globals
	{
		public	static const debug				:Boolean= false;
		public	static const fsdebug			:Boolean= false;
		
		public	static const CPU_FREQ_NTSC		:Number	= 1789772.5;
		public	static const CPU_FREQ_PAL		:Number	= 1773447.4;
		
		public	static var preferredFrameRate	:int	= 60;
		public	static var frameTime			:int	= 1000000/preferredFrameRate;
		public	static var memoryFlushValue		:int	= 0xFF;
		
		public	static var movieclipMode		:Boolean= true;
		public	static var disableSprites		:Boolean= false;
		public	static var timeEmulation		:Boolean= true;
		public	static var palEmulation			:Boolean;
		public	static var enableSound			:Boolean= true;
		public	static var focused				:Boolean= false;

		public	static var nes					:Nes;
		
		public function Globals()
		{
			;
		}

		public	static function println(str:String):void
		{
			nes.getGui().println(str);
		}
	}
}