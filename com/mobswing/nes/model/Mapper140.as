package com.mobswing.nes.model
{
	public class Mapper140 extends MapperDefault
	{
		public function Mapper140()
		{
			super();
		}

	    override public	function init(nes:Nes):void
	    {
	        super.init(nes);
	    }
	
        override public	function loadROM(rom:ROM):void
        {
	        if (!rom.isValid())
	        {
	            //System.out.println("Invalid ROM! Unable to load.");
	            return;
	        }
	
	        // Initial Load:
	        loadPRGROM();
	        loadCHRROM();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    override public	function write(address:int, value:int):void
	    {
	        if (address < 0x8000)
	        {
	            // Handle normally:
	            super.write(address, value);
	        } 
	
	        if (address >= 0x6000 && address < 0x8000)
	        {
	            var prg_bank:int = (value & 0xF0) >> 4;
	            var chr_bank:int = value & 0x0F;
	
	            load32kRomBank(prg_bank, 0x8000);
	            load8kVromBank(chr_bank, 0x0000);
	        }
	    }
	}
}