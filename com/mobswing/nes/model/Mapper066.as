package com.mobswing.nes.model
{
	public class Mapper066 extends MapperDefault
	{
		public function Mapper066()
		{
			super();
		}

		override public	function init(nes:Nes):void
		{
			super.init(nes);
		}
		
		override public	function write(address:int, value:int):void
		{
			if (address < 0x8000)
			{
				// Let the base mapper take care of it.
				super.write(address,value);
			}
			else
			{
				// Swap in the given PRG-ROM bank at 0x8000:
				load32kRomBank((value>>4)&3,0x8000);
				
				// Swap in the given VROM bank at 0x0000:
				load8kVromBank((value&3)*2,0x0000);
			}
		}
	}
}