package com.mobswing.model
{
	public class Mapper094 extends MapperDefault
	{
		public function Mapper094()
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
	            super.write(address, value);
	        }
	        else
	        {
	            if ((address & 0xFFF0) == 0xFF00)
	            {
	                var bank:int = (value & 0x1C) >> 2;
	                loadRomBank(bank, 0x8000);
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        var num_banks:int = rom.getRomBankCount();
	
	        // Load PRG-ROM:
	        loadRomBank(0, 0x8000);
	        loadRomBank(num_banks - 1, 0xC000);
	
	        // Load CHR-ROM:
	        loadCHRROM();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	}
}