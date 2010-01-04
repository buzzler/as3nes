package com.mobswing.nes.view
{
	import com.mobswing.nes.control.IInputHandler;
	import com.mobswing.nes.control.IUI;
	import com.mobswing.nes.control.KbInputHandler;
	import com.mobswing.nes.model.BootInfo;
	import com.mobswing.nes.model.Cartridge;
	import com.mobswing.nes.model.Globals;
	import com.mobswing.nes.model.HiResTimer;
	import com.mobswing.nes.model.Joystick;
	import com.mobswing.nes.model.Nes;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.system.System;

	public class As3nes extends Sprite implements IUI
	{
		private var sm				:Stage;
		private var nes				:Nes;
		private var timer			:HiResTimer;
		private var kbJoy1			:KbInputHandler;
		private var kbJoy2			:KbInputHandler;
		private var panelScreen		:ScreenView;
		private var rom				:String;
		private var started			:Boolean;
		
		private var sleepTime:int;
		private var t1:Number, t2:Number;
		
		public function As3nes(sm:Stage)
		{
			super();
			this.sm = sm;
			this.graphics.beginFill(0x0);
			this.graphics.drawRect(0,0,Globals.WIDTH, Globals.HEIGHT);
			this.graphics.endFill();
		}

		public	function startEmulation(game:Cartridge, option:BootInfo = null):void
		{
			System.gc();
			if (option == null)
				option = new BootInfo();
			
			this.timer	= new HiResTimer();
			this.nes	= new Nes(this);
			this.kbJoy1	= new KbInputHandler(this.nes, 0);
			this.kbJoy2	= new KbInputHandler(this.nes, 1);
			
			this.panelScreen = new ScreenView(this.nes, Globals.WIDTH, Globals.HEIGHT);
			this.panelScreen.init();
			this.panelScreen.setNotifyImageReady(true);
			this.panelScreen.addKeyListener(this.kbJoy1);
			this.panelScreen.addKeyListener(this.kbJoy2);

			if (option.joystick1)
				this.setJoystick(this.kbJoy1, option.joystick1);
			if (option.joystick2)
				this.setJoystick(this.kbJoy2, option.joystick2);
			
			Globals.memoryFlushValue = 0;
			
			this.nes.enableSound(option.sound);
			this.nes.reset();
			this.started = true;
			
			trace("AS3NES 2009 Shim KyungHyun");
			trace("Use of this program subject to GNU GPL, Version 3.");
			
			this.nes.loadRom(game);
			if (this.nes.getRom().isValid())
			{
				this.addChild(this.panelScreen);
				
				Globals.timeEmulation = option.timeemulation;
				this.nes.getCpu().beginExcution();
			}
			else
			{
				trace("AS3NES was unable to open this cartridge.");
			}
		}
		
		public	function get isRunning():Boolean
		{
			return this.started;
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
			return this.panelScreen;
		}
		
		public function getStage():Stage
		{
			//return this.stage;
			return sm;
		}
		
		public function imageReady(skipFrame:Boolean):void
		{
			var tmp:int = this.nes.getPapu().bufferIndex;
			if (Globals.enableSound && Globals.timeEmulation && tmp > 0)
			{
				var min_avail:int = this.nes.getPapu().getLine().getBufferSize()-2*tmp;
				this.timer.sleepMillis(this.nes.getPapu().getMillisToAvailableAbove(min_avail));
				while (this.nes.getPapu().getLine().available() < min_avail)
				{
					this.timer.yield();
				}
				this.nes.getPapu().writeBuffer();
			}
			
			if (Globals.timeEmulation && (!Globals.enableSound))
			{
				sleepTime = Globals.frameTime;
				t2 = this.timer.currentMillis();
 				if ((t2 - t1) < sleepTime)
				{
					this.timer.sleepMillis(sleepTime - (t2-t1));
				}
			}
			
			t1 = t2;
		}
		
		public	function stopEmulation():void
		{
			this.nes.stopEmulation();
			this.nes.getPapu().stop();
			this.destroy();
			this.started = false;
		}
		
		public	function setJoy1(joystick:Joystick):void
		{
			setJoystick(this.kbJoy1, joystick);
		}
		
		public	function setJoy2(joystick:Joystick):void
		{
			setJoystick(this.kbJoy2, joystick);
		}
		
		private	function setJoystick(kbJoy:KbInputHandler, joystick:Joystick):void
		{
			kbJoy.mapKey(KbInputHandler.KEY_A,		joystick.A);
			kbJoy.mapKey(KbInputHandler.KEY_B,		joystick.B);
			kbJoy.mapKey(KbInputHandler.KEY_START,	joystick.START);
			kbJoy.mapKey(KbInputHandler.KEY_SELECT,joystick.SELECT);
			kbJoy.mapKey(KbInputHandler.KEY_DOWN,	joystick.DOWN);
			kbJoy.mapKey(KbInputHandler.KEY_LEFT,	joystick.LEFT);
			kbJoy.mapKey(KbInputHandler.KEY_RIGHT,	joystick.RIGHT);
			kbJoy.mapKey(KbInputHandler.KEY_UP,	joystick.UP);
		}
		
		public	function reset():void
		{
			if (this.nes.isRunning())
			{
				nes.stopEmulation();
                nes.reset();
                nes.reloadRom();
                nes.startEmulation();
			}
		}
		
		public	function set volume(value:Number):void
		{
			Globals.volume = value;
		}
		
		public	function get volume():Number
		{
			return Globals.volume;
		}
		
		public	function get fps():Number
		{
			return this.panelScreen.FPS;
		}
		
		public function showErrorMessage(msg:String):void
		{
			trace(msg);
		}
		
		private	function destroy():void
		{
			if (this.nes != null && this.nes.getCpu().isRunning())
			{
				stopEmulation();
			}
			if (this.panelScreen)
			{
				this.panelScreen.destroy();
				this.removeChild(this.panelScreen);
			}
			if (this.kbJoy1) this.kbJoy1.destroy();
			if (this.kbJoy2) this.kbJoy2.destroy();
			if (this.nes != null) this.nes.destroy();
			
			this.nes = null;
			this.panelScreen = null;
			this.rom = null;
			this.kbJoy1 = null;
			this.kbJoy2 = null;
			this.panelScreen= null;
			this.timer	= null;
			
//			System.exit(0);
			System.gc();
		}
	}
}