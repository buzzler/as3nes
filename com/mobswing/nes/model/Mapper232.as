package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper232 extends MapperDefault
	{
		public function Mapper232()
		{
			super();
		}

	    private var regs232:Vector.<int> = new Vector.<int>(2);
	
	    override public	function init(nes:Nes):void
	    {
	        super.init(nes);
	        reset();
	    }
	
	    override public	function write(address:int, value:int):void
	    {
	        if (address < 0x8000)
	        {
	            // Handle normally:
	            super.write(address, value);
	
	        }
	        else if (address == 0x9000)
	        {
	            regs232[0] = (value & 0x18) >> 1;
	        }
	        else if (0xA000 <= address && address <= 0xFFFF)
	        {
	            regs232[1] = value & 0x03;
	        }
	
	        loadRomBank((regs232[0] | regs232[1]), 0x8000);
	        loadRomBank((regs232[0] | 0x03), 0xC000);
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
	        loadRomBank((regs232[0] | regs232[1]), 0x8000);
	        loadRomBank((regs232[0] | 0x03), 0xC000);
	
	        // Load CHR-ROM:
	        loadCHRROM();
	
	        // Load Battery RAM (if present):
	        loadBatteryRam();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    override public	function reset():void
	    {
	        regs232[0] = 0x0C;
	        regs232[1] = 0x00;
	    }
	}
}