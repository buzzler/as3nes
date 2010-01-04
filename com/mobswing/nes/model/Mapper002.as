package com.mobswing.nes.model
{
	public class Mapper002 extends MapperDefault
	{
		public function Mapper002()
		{
			super();
		}

		override public	function init(nes:Nes):void
		{
			super.init(nes);
		}
		
		override public function write(address:int, value:int):void
		{
			if (address < 0x8000)
			{
				// Let the base mapper take care of it.
				super.write(address,value);
			}
			else
			{
				// This is a ROM bank select command.
				// Swap in the given ROM bank at 0x8000:
				loadRomBank(value,0x8000);
			}
		}
		
		override public function loadROM(rom:ROM):void
		{
			if (!rom.isValid())
			{
				//System.out.println("UNROM: Invalid ROM! Unable to load.");
				return;
			}
			
			//System.out.println("UNROM: loading ROM..");
			
			// Load PRG-ROM:
			loadRomBank(0,0x8000);
			loadRomBank(rom.getRomBankCount()-1,0xC000);
			
			// Load CHR-ROM:
			loadCHRROM();
			
			// Do Reset-Interrupt:
			//nes.getCpu().doResetInterrupt();
			nes.getCpu().requestIrq(CPU.IRQ_RESET);
		}
	}
}