package com.mobswing.model
{
	import flash.utils.ByteArray;
	
	public class Cartridge
	{
		public	var rom	:ByteArray;
		public	var ram	:String;

		public function Cartridge(rom:ByteArray, ram:String = null)
		{
			this.rom = rom;
			this.ram = ram;
			
			if (ram == null)
			{
				this.ram = '';
				for (var i:int = 0 ; i < 0x2000 ; i++)
				{
					this.ram += '00';
				}
			}
		}
	}
}