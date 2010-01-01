package com.mobswing.model
{
	public class Mapper071 extends MapperDefault
	{

		private var curBank:int;

		public	function Mapper071()
		{
			super();
		}
		
		override public	function init(nes:Nes):void
		{
			super.init(nes);
			reset();
		}
		
		override public	function loadROM(rom:ROM):void
		{
			//System.out.println("Loading ROM.");
		
			if (!rom.isValid())
			{
				//System.out.println("Camerica: Invalid ROM! Unable to load.");
				return;
			}
			
			// Get number of PRG ROM banks:
			var num_banks:int = rom.getRomBankCount();
			
			// Load PRG-ROM:
			loadRomBank(          0,0x8000);
			loadRomBank(num_banks-1,0xC000);
			
			// Load CHR-ROM:
			loadCHRROM();
			
			// Load Battery RAM (if present):
			loadBatteryRam();
			
			// Do Reset-Interrupt:
			nes.getCpu().requestIrq(CPU.IRQ_RESET);
		}
		
		override public	function write(address:int, value:int):void
		{
			if (address < 0x8000)
			{
				// Handle normally:
				super.write(address,value);
			}
			else if (address < 0xC000)
			{
				// Unknown function.
			}
			else
			{
				// Select 16K PRG ROM at 0x8000:
				if (value != curBank)
				{
					curBank = value;
					loadRomBank(value,0x8000);
				}
			}
		}
		
		override public	function reset():void
		{
			curBank = -1;
		}
	}
}