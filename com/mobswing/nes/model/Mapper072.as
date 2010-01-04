package com.mobswing.nes.model
{
	public class Mapper072 extends MapperDefault
	{
		public function Mapper072()
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
	            super.write(address, value);
	        }
	        else
	        {
	            var bank:int = value & 0x0f;
	            var num_banks:int = rom.getRomBankCount();
	
	            if ((value & 0x80) != 0)
	            {
	                loadRomBank(bank * 2, 0x8000);
	                loadRomBank(num_banks - 1, 0xC000);
	            }
	            if ((value & 0x40) != 0)
	            {
	                load8kVromBank(bank * 8, 0x0000);
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        if (!rom.isValid())
	        {
	            trace("048: Invalid ROM! Unable to load.");
	            return;
	        }
	
	        // Get number of 8K banks:
	        var num_banks:int = rom.getRomBankCount() * 2;
	
	        // Load PRG-ROM:
	        loadRomBank(1, 0x8000);
	        loadRomBank(num_banks - 1, 0xC000);
	
	        // Load CHR-ROM:
	        loadCHRROM();
	
	        // Load Battery RAM (if present):
	        // loadBatteryRam();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	}
}