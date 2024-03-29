package com.mobswing.nes.view
{
	import com.mobswing.nes.model.Globals;
	import com.mobswing.nes.model.Nes;
	
	import flash.events.MouseEvent;
	
	public class ScreenView extends BufferView
	{
		private var notifyImageReady:Boolean;
		private var lastClickTime	:Number = 0;
		
		public function ScreenView(nes:Nes, width:int, height:int)
		{
			super(nes, width, height);
		}

		override public	function init():void
		{
			super.init();
		}
		
		public	function setNotifyImageReady(value:Boolean):void
		{
			this.notifyImageReady = value;
		}
		
		override public	function imageReady(skipFrame:Boolean):void
		{
			super.imageReady(skipFrame);
			
			if (this.notifyImageReady)
			{
				this.nes.getGui().imageReady(skipFrame);
			}
		}
		
		private function onClick(event:MouseEvent):void
		{
			;
		}
		
		private function onDown(event:MouseEvent):void
		{
			if (event.localX >= 0 && event.localX < Globals.WIDTH && event.localY >= 0 && event.localY < Globals.HEIGHT)
			{
				if (this.nes != null && this.nes.memMapper != null)
				{
					this.nes.memMapper.setMouseState(true, event.localX, event.localY);
				}
			}
		}
		
		private function onUp(event:MouseEvent):void
		{
			if (this.nes != null && this.nes.memMapper != null)
			{
				this.nes.memMapper.setMouseState(false, 0, 0);
			}
		}
	}
}