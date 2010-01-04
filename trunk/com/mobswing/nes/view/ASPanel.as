package com.mobswing.view
{
	import com.mobswing.control.KbInputHandler;
	import com.mobswing.model.Globals;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	public class ASPanel extends Bitmap
	{
		private var listeners:Array;
		
		public function ASPanel()
		{
			super(new BitmapData(Globals.WIDTH,Globals.HEIGHT,false,Globals.bgColor));
			listeners = new Array();
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			for each (var listener:KbInputHandler in this.listeners)
			{
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN, listener.keyPressed);
				this.stage.addEventListener(KeyboardEvent.KEY_UP, listener.keyReleased);
			}
		}

		public	function addKeyListener(listener:KbInputHandler):void
		{
			if (this.stage)
			{
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN, listener.keyPressed);
				this.stage.addEventListener(KeyboardEvent.KEY_UP, listener.keyReleased);
			}
			this.listeners.push(listener);
		}
		
		public	function removeAllKeyListener():void
		{
			for each (var listener:KbInputHandler in this.listeners)
			{
				this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, listener.keyPressed);
				this.stage.removeEventListener(KeyboardEvent.KEY_UP, listener.keyReleased);
			}
		}
	}
}