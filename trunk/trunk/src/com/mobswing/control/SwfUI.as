package com.mobswing.control
{
	import com.mobswing.model.Globals;
	import com.mobswing.model.HiResTimer;
	import com.mobswing.model.Nes;
	import com.mobswing.view.As3nes;
	import com.mobswing.view.BufferView;
	import com.mobswing.view.ScreenView;
	
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.ui.Keyboard;

	public class SwfUI implements IUI
	{
		private var as3nes:As3nes;
		private var nes:Nes;
		private var kbJoy1:KbInputHandler;
		private var kbJoy2:KbInputHandler;
		private var vScreen:ScreenView;
		private var timer:HiResTimer;
		
		private var sleepTime:int;
		private var t1:Number, t2:Number;
		
		public function SwfUI(as3nes:As3nes)
		{
			this.as3nes = as3nes;
			this.timer = new HiResTimer();
			this.nes = new Nes(this);
		}

		public function getNes():Nes
		{
			return this.nes;
		}
		
		public function getJoy1():IInputHandler
		{
			return this.kbJoy1;
		}
		
		public function getJoy2():IInputHandler
		{
			return this.kbJoy2;
		}
		
		public function getScreenView():BufferView
		{
			return this.vScreen;
		}
		
		public function getPatternView():BufferView
		{
			return null;
		}
		
		public function getSprPalView():BufferView
		{
			return null;
		}
		
		public function getImgPalView():BufferView
		{
			return null;
		}
		
		public function getNameTableView():BufferView
		{
			return null;
		}
		
		public function getTimer():HiResTimer
		{
			return this.timer;
		}
		
		public function getStage():Stage
		{
			return this.as3nes.stage;
		}
		
		public function imageReady(skipFrame:Boolean):void
		{
			var tmp:int = this.nes.getPapu().bufferIndex;
			if (Globals.enableSound && Globals.timeEmulation && tmp > 0)
			{
				var min_avail:int = this.nes.getPapu().line.getBufferSize()-4*tmp;
				this.timer.sleepMicros(this.nes.getPapu().getMillisToAvailableAbove(min_avail));
				while (this.nes.getPapu().line.available() < min_avail)
				{
					this.timer.yield();
				}
				this.nes.getPapu().writeBuffer();
			}
			
			if (Globals.timeEmulation && Globals.enableSound)
			{
				sleepTime = Globals.frameTime;
				t2 = this.timer.currentMicros();
				if (t2 - t1 < sleepTime)
				{
					this.timer.sleepMicros(sleepTime - (t2-t1));
				}
			}
			
			t1 = t2;
		}
		
		public function init(showGui:Boolean):void
		{
			this.vScreen = new ScreenView(this.nes, 256, 240);
			this.vScreen.setBgColor(as3nes.bgColor);
			this.vScreen.init();
			this.vScreen.setNotifyImageReady(true);
			
			this.kbJoy1 = new KbInputHandler(this.nes, 0);
			this.kbJoy2 = new KbInputHandler(this.nes, 1);
			
			this.kbJoy1.mapKey(KbInputHandler.KEY_A,		Keyboard.CONTROL);
			this.kbJoy1.mapKey(KbInputHandler.KEY_B,		Keyboard.SHIFT);
			this.kbJoy1.mapKey(KbInputHandler.KEY_START,	Keyboard.ENTER);
			this.kbJoy1.mapKey(KbInputHandler.KEY_SELECT,Keyboard.TAB);
			this.kbJoy1.mapKey(KbInputHandler.KEY_DOWN,	Keyboard.DOWN);
			this.kbJoy1.mapKey(KbInputHandler.KEY_LEFT,	Keyboard.LEFT);
			this.kbJoy1.mapKey(KbInputHandler.KEY_RIGHT,	Keyboard.RIGHT);
			this.kbJoy1.mapKey(KbInputHandler.KEY_UP,	Keyboard.UP);
			this.vScreen.addKeyListener(this.kbJoy1);
			
			this.kbJoy2.mapKey(KbInputHandler.KEY_A,		Keyboard.NUMPAD_7);
			this.kbJoy2.mapKey(KbInputHandler.KEY_B,		Keyboard.NUMPAD_9);
			this.kbJoy2.mapKey(KbInputHandler.KEY_START,	Keyboard.NUMPAD_1);
			this.kbJoy2.mapKey(KbInputHandler.KEY_SELECT,Keyboard.NUMPAD_3);
			this.kbJoy2.mapKey(KbInputHandler.KEY_DOWN,	Keyboard.NUMPAD_2);
			this.kbJoy2.mapKey(KbInputHandler.KEY_LEFT,	Keyboard.NUMPAD_4);
			this.kbJoy2.mapKey(KbInputHandler.KEY_RIGHT,	Keyboard.NUMPAD_6);
			this.kbJoy2.mapKey(KbInputHandler.KEY_UP,	Keyboard.NUMPAD_8);
			this.vScreen.addKeyListener(this.kbJoy2);
		}
		
		public function getWindowCaption():String
		{
			return "";
		}
		
		public function setWindowCaption(str:String):void
		{
		}
		
		public function setTitle(str:String):void
		{
		}
		
		public function getLocation():Point
		{
			return new Point(0,0);
		}
		
		public function getWidth():int
		{
			return this.as3nes.getWidth();
		}
		
		public function getHeight():int
		{
			return this.as3nes.getHeight();
		}
		
		public function getRomFileSize():int
		{
			return this.as3nes.romSize;
		}
		
		public function destroy():void
		{
			if (this.vScreen) this.vScreen.destroy();
			if (this.kbJoy1) this.kbJoy1.destroy();
			if (this.kbJoy2) this.kbJoy2.destroy();
			
			this.nes	= null;
			this.as3nes = null;
			this.kbJoy1 = null;
			this.kbJoy2 = null;
			this.vScreen= null;
			this.timer	= null;
		}
		
		public function println(str:String):void
		{
		}
		
		public function showLoadProgress(percentComplete:int):void
		{
			this.as3nes.showLoadProgress(percentComplete);
			
			timer.sleepMicros(20*1000);
		}
		
		public function showErrorMessage(msg:String):void
		{
			trace(msg);
		}
		
	}
}