package com.mobswing.model
{
	public class Mapper087 extends MapperDefault
	{
		public function Mapper087()
		{
			super();
		}

	    override public	function init(nes:Nes):void
	    {
	        super.init(nes);
	    }
	
	    override public	function writelow(address:int, value:int):void
	    {
	        if (address < 0x6000)
	        {
	            // Let the base mapper take care of it.
	            super.writelow(address, value);
	        }
	        else if (address == 0x6000)
	        {
	            var chr_bank:int = (value & 0x02) >> 1;
	            load8kVromBank(chr_bank * 8, 0x0000);
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        if (!rom.isValid())
	        {
	            trace("Invalid ROM! Unable to load.");
	            return;
	        }
	
	        // Get number of 8K banks:
	        var num_8k_banks:int = rom.getRomBankCount() * 2;
	
	        // Load PRG-ROM:
	        load8kRomBank(0, 0x8000);
	        load8kRomBank(1, 0xA000);
	        load8kRomBank(2, 0xC000);
	        load8kRomBank(3, 0xE000);
	
	        // Load CHR-ROM:
	        loadCHRROM();
	
	        // Load Battery RAM (if present):
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	}
}