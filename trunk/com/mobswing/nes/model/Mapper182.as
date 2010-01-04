package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper182 extends MapperDefault
	{

	    private var irq_counter:int = 0;
	    private	var irq_enabled:Boolean = false;
	    private var regs:Vector.<int> = new Vector.<int>(1);
	
		public function Mapper182()
		{
			super();
		}
		
	    override public	function init(nes:Nes):void
	    {
	        super.init(nes);
	        reset();
	    }
	
	    override public	function write(address:int, value:int):void
	    {
	        if (address < 0x8000)
	        {
	            super.write(address, value);
	        }
	        else
	        {
	            switch (address & 0xF003)
	            {
                case 0x8001:
                    if ((value & 0x01) != 0) {
                        nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                    } else {
                        nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                    }
                    break;
                case 0xA000:
                    regs[0] = value & 0x07;
                    break;
                case 0xC000:
                    switch (regs[0])
                    {
                    case 0x00:
                        load2kVromBank(value, 0x0000);
                        break;
                    case 0x01:
                        load1kVromBank(value, 0x1400);
                        break;
                    case 0x02:
                        load2kVromBank(value, 0x0800);
                        break;
                    case 0x03:
                        load1kVromBank(value, 0x1C00);
                        break;
                    case 0x04:
                        load8kRomBank(value, 0x8000);
                        break;
                    case 0x05:
                        load8kRomBank(value, 0xA000);
                        break;
                    case 0x06:
                        load1kVromBank(value, 0x1000);
                        break;
                    case 0x07:
                        load1kVromBank(value, 0x1800);
                        break;
                    }
                    break;
                case 0xE003:
                    irq_counter = value;
                    irq_enabled = (value != 0);
                    break;
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        if (!rom.isValid())
	        {
	            trace("182: Invalid ROM! Unable to load.");
	            return;
	        }
	
	        // Get number of 8K banks:
	        var num_8k_banks:int = rom.getRomBankCount() * 2;
	
	        // Load PRG-ROM:
	        load8kRomBank(0, 0x8000);
	        load8kRomBank(1, 0xA000);
	        load8kRomBank(num_8k_banks - 2, 0xC000);
	        load8kRomBank(num_8k_banks - 1, 0xE000);
	
	        // Load CHR-ROM:
	        loadCHRROM();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    public	function syncH(scanline:int):int
	    {
	        if (irq_enabled)
	        {
	            if ((scanline >= 0) && (scanline <= Globals.HEIGHT))
	            {
	                if ((ppu.scanline & 0x18) != 00)
	                {
	                    if (0 == (--irq_counter))
	                    {
	                        irq_counter = 0;
	                        irq_enabled = false;
	                        return 3;
	                    }
	                }
	            }
	        }
	        return 0;
	    }
	
	    override public	function reset():void
	    {
	        irq_enabled = false;
	        irq_counter = 0;
	    }
	}
}