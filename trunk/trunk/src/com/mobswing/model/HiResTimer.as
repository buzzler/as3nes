package com.mobswing.model
{
	import flash.utils.getTimer;

	public class HiResTimer
	{
		private var offset:Number;

		public function HiResTimer()
		{
			offset = new Date().time;
		}

		public	function currentMicros():Number
		{
			return offset + getTimer() * 1000;
		}
		
		public	function currentTick():Number
		{
			return offset + getTimer() * 1000000;
		}
	
		public	function yield():void
		{
			//Thread.yield();
		}
		
		public	function sleepMicros(time:Number):void
		{
			try{
				//Thread.yield();
				var nanos:Number = time - (time/1000)*1000;
				if(nanos > 999999)
					nanos = 999999;
				//Thread.sleep(time/1000,(int)nanos);
				
			}
			catch(e:Error)
			{
				trace(e);
			}	
		}
	}
}