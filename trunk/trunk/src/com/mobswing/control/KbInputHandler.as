package com.mobswing.control
{
	import com.mobswing.model.Nes;
	
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
		
		// Key count:
		public	static const NUM_KEYS	:int = 8;

		private var nes:Nes;
		private var id:int;

		public function KbInputHandler(nes:Nes, id:int)
		{
			this.nes = nes;
			this.id = id;
		}
		
		public	function destroy():void
		{
			this.nes = null;
		}

		public function getKeyState(padKey:int):int
		{
			return 0;
		}
		
		public function mapKey(padKey:int, deviceKey:int):void
		{
		}
		
		public function reset():void
		{
		}
		
		public function update():void
		{
		}
		
	}
}