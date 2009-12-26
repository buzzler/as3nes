package com.mobswing.view
{
	import com.mobswing.control.KbInputHandler;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	public class ASPanel extends Sprite
	{
		private var listeners:Array;
		
		public function ASPanel()
		{
			super();
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
		
		public	function getWidth():int
		{
			return this.width;
		}
		
		public	function getHeight():int
		{
			return this.height;
		}

		public	function setSize(width:int, height:int):void
		{
		}
		
		public	function setBounds(x:int, y:int, width:int, height:int):void
		{
		}
	}
}