package com.mobswing.control
{
	import flash.utils.getTimer;
	public class Debug
	{
		public function Debug()
		{
		}
		
		private static var t:Number = getTimer();
		public	static function timerStamp(label:String = '', print:Boolean = false):void
		{
			var tt:int = getTimer();
			if (print&&(tt-t > 20))
				trace(label, tt - t);
			t = tt;
		}
	}
}