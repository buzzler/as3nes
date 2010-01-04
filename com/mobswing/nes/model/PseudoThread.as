package com.mobswing.nes.model
{
 import flash.display.Sprite;
 import flash.display.Stage;
 import flash.events.Event;
 import flash.events.EventDispatcher;
 import flash.events.KeyboardEvent;
 import flash.events.MouseEvent;
 import flash.utils.getTimer;
 
 public class PseudoThread extends EventDispatcher
 {
 	private	static var hash:Object;
 	public	static function getThread(id:String):PseudoThread
 	{
 		return hash[id] as PseudoThread;
 	}
 	
	 // number of milliseconds we think it takes to render the screen
	public	var RENDER_DEDUCTION:int = 1;

	private var sm		:Stage;
	private var fn		:Function;
	private var obj		:Object;
	private var thread	:Sprite;
	private var start	:Number;
	private var fr		:Number;
	private var due		:Number;

	private var locked		:Boolean;
	private var alive		:Boolean = true;
	private var mouseEvent	:Boolean;
	private var keyEvent	:Boolean;
	 
	 public function PseudoThread(sm:Stage, threadFunction:Function, threadObject:Object, id:String)
	 {
	 	this.sm = sm;
		fn = threadFunction;
		obj = threadObject;
		locked = false;

		// add high priority listener for ENTER_FRAME
		sm.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 100);
		sm.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		sm.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

		thread = new Sprite();
		sm.addChild(thread);
		thread.addEventListener(Event.RENDER, renderHandler);
		
		fr = Math.floor(1000 / thread.stage.frameRate);
		
		if (hash == null) hash = new Object();
		hash[id] = this;
	 }
	 
	 public	function isAlive():Boolean
	 {
	 	return this.alive;
	 }

	public	function lock():void
	{
		this.locked = true;
	}

	public	function unlock():void
	{
		this.locked = false;
	}

	 private function enterFrameHandler(event:Event):void
	 {
		due = getTimer() + fr;
		thread.stage.invalidate();
		thread.graphics.clear();
		thread.graphics.moveTo(0, 0);
		thread.graphics.lineTo(0, 0);	
	 }

	 private function renderHandler(event:Event):void
	 {
		if (mouseEvent || keyEvent)
			due -= RENDER_DEDUCTION;

		while (getTimer() < due)
		{
			if (this.locked)
				continue;
			 
			if (!fn(obj))
			{
				if (!thread.parent)
					return;

				sm.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				sm.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				sm.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				sm.removeChild(thread);
				thread.removeEventListener(Event.RENDER, renderHandler);
				this.alive = false;
				dispatchEvent(new Event(Event.COMPLETE));
			} 
		}

		mouseEvent = false;
		keyEvent = false;
	 }

	 private function mouseMoveHandler(event:Event):void
	 {
		mouseEvent = true;
	 }

	 private function keyDownHandler(event:Event):void
	 {
		keyEvent = true;
	 }
	 
	public	function destroy():void
	 {
		sm.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		sm.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		sm.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		sm.removeChild(thread);
		thread.removeEventListener(Event.RENDER, renderHandler);
		this.alive = false;
		dispatchEvent(new Event(Event.COMPLETE));
	 }
 } 
}
