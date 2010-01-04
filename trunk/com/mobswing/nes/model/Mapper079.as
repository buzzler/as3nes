package com.mobswing.nes.model
{
	public class Mapper079 extends MapperDefault
	{
		public function Mapper079()
		{
			super();
		}

	    override public	function init(nes:Nes):void
	    {
	        super.init(nes);
	    }
	
	    override public	function writelow(address:int, value:int):void
	    {
	        if (address < 0x4000)
	        {
	            super.writelow(address, value);
	        } 
	        
	        if ((address < 0x6000) && (address >= 0x4100))
	        {
	            var prg_bank:int = (value & 0x08) >> 3;
	            var chr_bank:int = value & 0x07;
	
	            load32kRomBank(prg_bank, 0x8000);
	            load8kVromBank(chr_bank, 0x0000);
	        }
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
	}
}