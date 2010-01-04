package com.mobswing.nes.control
{
	import __AS3__.vec.Vector;
	
	import com.mobswing.nes.model.Nes;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class KbInputHandler implements IInputHandler
	{
		// Joypad keys:
		public	static const KEY_A		:int = 0;
		public	static const KEY_B		:int = 1;
		public	static const KEY_START	:int = 2;
		public	static const KEY_SELECT	:int = 3;
		public	static const KEY_UP		:int = 4;
		public	static const KEY_DOWN	:int = 5;
		public	static const KEY_LEFT	:int = 6;
		public	static const KEY_RIGHT	:int = 7;
		public	static const NUM_KEYS	:int = 8;

		private var allKeysState:Vector.<Boolean>;
    	private var keyMapping:Vector.<int>;
		private var nes:Nes;
		private var id:int;

		public function KbInputHandler(nes:Nes, id:int)
		{
			this.nes = nes;
			this.id = id;
			this.allKeysState = new Vector.<Boolean>(255);
			this.keyMapping = new Vector.<int>(NUM_KEYS);
		}
		

		public function getKeyState(padKey:int):int
		{
			return this.allKeysState[keyMapping[padKey]] ? 0x41 : 0x40;
		}
		
		public function mapKey(padKey:int, deviceKey:int):void
		{
			this.keyMapping[padKey] = deviceKey;
		}

		public	function keyPressed(ke:KeyboardEvent):void
		{
	
	        var kc:int = ke.keyCode;
	        if (kc >= allKeysState.length)
	        {
	            return;
	        }
	
	        allKeysState[kc] = true;
	
	        if (kc == keyMapping[KEY_LEFT])
	        {
	            allKeysState[keyMapping[KEY_RIGHT]] = false;
	        }
	        else if (kc == keyMapping[KEY_RIGHT])
	        {
	            allKeysState[keyMapping[KEY_LEFT]] = false;
	        }
	        else if (kc == keyMapping[KEY_UP])
	        {
	            allKeysState[keyMapping[KEY_DOWN]] = false;
	        }
	        else if (kc == keyMapping[KEY_DOWN])
	        {
	            allKeysState[keyMapping[KEY_UP]] = false;
	        }
	    }
	
	    public	function keyReleased(ke:KeyboardEvent):void
	    {
	        var kc:int = ke.keyCode;
	        if (kc >= allKeysState.length)
	        {
	            return;
	        }
	
	        allKeysState[kc] = false;
	    }

		public function reset():void
		{
			this.allKeysState = new Vector.<Boolean>(255);
		}
		
		public	function destroy():void
		{
			this.nes = null;
		}

	}
}