package com.mobswing.view
{
	import com.mobswing.model.Nes;
	
	public class ScreenView extends BufferView
	{
		private var notifyImageReady:Boolean;
		
		public function ScreenView(nes:Nes, width:int, height:int)
		{
			//super(nes, width, height);
		}

		public	function init():void
		{
			;
		}
		
		public	function setNotifyImageReady(value:Boolean):void
		{
			this.notifyImageReady = value;
		}
	}
}