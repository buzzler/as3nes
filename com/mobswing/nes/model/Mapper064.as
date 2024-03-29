package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper064 extends MapperDefault
	{

	    private	var irq_counter:int = 0;
	    private	var irq_latch:int = 0;
	    private	var irq_enabled:Boolean = false;
	    private var regs:Vector.<int> = new Vector.<int>(3);

		public	function Mapper064()
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
	            // Normal memory write.
	            super.write(address, value);
	            return;
	        }
	
	        switch (address & 0xF003)
	        {
            case 0x8000:
                regs[0] = value & 0x0F;
                regs[1] = value & 0x40;
                regs[2] = value & 0x80;
                break;
            case 0x8001:
                switch (regs[0])
                {
                case 0x00:
                    if (regs[2] != 0)
                    {
                        load2kVromBank(value, 0x1000);
                    }
                    else
                    {
                        load2kVromBank(value, 0x0000);
                    }
                    break;
                case 0x01:
                    if (regs[2] != 0)
                    {
                        load2kVromBank(value, 0x1800);
                    }
                    else
                    {
                        load2kVromBank(value, 0x0800);
                    }
                    break;
                case 0x02:
                    if (regs[2] != 0)
                    {
                        load1kVromBank(value, 0x0000);
                    }
                    else
                    {
                        load1kVromBank(value, 0x1000);
                    }
                    break;
                case 0x03:
                    if (regs[2] != 0)
                    {
                        load1kVromBank(value, 0x0400);
                    }
                    else
                    {
                        load1kVromBank(value, 0x1400);
                    }
                    break;
                case 0x04:
                    if (regs[2] != 0)
                    {
                        load1kVromBank(value, 0x0800);
                    }
                    else
                    {
                        load1kVromBank(value, 0x1800);
                    }
                    break;
                case 0x05:
                    if (regs[2] != 0)
                    {
                        load1kVromBank(value, 0x0C00);
                    }
                    else
                    {
                        load1kVromBank(value, 0x1C00);
                    }
                    break;
                case 0x06:
                    if (regs[1] != 0)
                    {
                        load8kRomBank(value, 0xA000);
                    }
                    else
                    {
                        load8kRomBank(value, 0x8000);
                    }
                    break;
                case 0x07:
                    if (regs[1] != 0)
                    {
                        load8kRomBank(value, 0xC000);
                    }
                    else
                    {
                        load8kRomBank(value, 0xA000);
                    }
                    break;
                case 0x08:
                    load1kVromBank(value, 0x0400);
                    break;
                case 0x09:
                    load1kVromBank(value, 0x0C00);
                    break;
                case 0x0F:
                    if (regs[1] != 0)
                    {
                        load8kRomBank(value, 0x8000);
                    }
                    else
                    {
                        load8kRomBank(value, 0xC000);
                    }
                    break;
                }
                break;
            case 0xA000:
                if ((value & 0x01) == 0)
                {
                    nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                }
                else
                {
                    nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                }
                break;
            case 0xC000:
                irq_latch = value;
                irq_counter = irq_latch;
                break;
            case 0xC001:
                irq_counter = irq_latch;
                break;
            case 0xE000:
                irq_enabled = false;
                irq_counter = irq_latch;
                break;
            case 0xE001:
                irq_enabled = true;
                irq_counter = irq_latch;
                break;
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        //System.out.println("Loading ROM.");
	        if (!rom.isValid())
	        {
	            //System.out.println("MMC3: Invalid ROM! Unable to load.");
	            return;
	        }
	
	        var chr_banks:int = rom.getVromBankCount() * 4;
	        var num_8k_banks:int = rom.getRomBankCount() * 2;
	
	        // Load PRG-ROM:
	        load8kRomBank(0, 0x8000);
	        load8kRomBank(1, 0xA000);
	        load8kRomBank(num_8k_banks - 2, 0xC000);
	        load8kRomBank(num_8k_banks - 1, 0xE000);
	
	        load8kVromBank(0, 0x0000);
	
	        trace("CHR = "+chr_banks+"");
	
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    public	function syncH(scanline:int):int
	    {
	        if (irq_enabled)
	        {
	            if ((scanline >= 0) && (scanline <= 239))
	            {
	                if ((ppu.scanline & 0x18) != 00)
	                {
	                    if ((--irq_counter) == 0)
	                    {
	                        irq_counter = irq_latch;
	                        return 3;
	                    }
	                }
	            }
	        }
	        return 0;
	    }
	
	    override public	function reset():void
	    {
	        // Set Interrupts
	        irq_latch = 0;
	        irq_counter = 0;
	        irq_enabled = false;
	
	        regs[0] = 0;
	        regs[1] = 0;
	        regs[2] = 0;
	    }
	}
}