package com.mobswing.nes.model
{
	import flash.utils.getTimer;

	public class HiResTimer
	{
		private var offset:Number;

		public function HiResTimer()
		{
			offset = new Date().time;
		}

		public	function currentMillis():Number
		{
			return offset + getTimer();
		}

		public	function yield():void
		{
			/* Thread.yield(); */
		}
		
		public	function sleepMillis(time:Number):void
		{
 			try{
				/* Thread.yield(); */
				var curT:int = getTimer();
				var tarT:int = curT + time;
				while (curT < tarT)
				{
					curT = getTimer();
				}
			}
			catch(e:Error)
			{
				trace(e);
			}	
		}
	}
}