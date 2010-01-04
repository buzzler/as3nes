package com.mobswing.model
{
	public class Mapper011 extends MapperDefault
	{
		public function Mapper011()
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
				// Swap in the given PRG-ROM bank:
				var prgbank1:int = ((value&0xF)*2)%nes.getRom().getRomBankCount();
				var prgbank2:int = ((value&0xF)*2+1)%nes.getRom().getRomBankCount();
				
				loadRomBank(prgbank1,0x8000);
				loadRomBank(prgbank2,0xC000);
				
				if (rom.getVromBankCount() > 0)
				{
					// Swap in the given VROM bank at 0x0000:
					var bank:int = ((value>>4)*2)%(nes.getRom().getVromBankCount());
					loadVromBank(bank,0x0000);
					loadVromBank(bank+1,0x1000);
				}
			}
		}
	}
}