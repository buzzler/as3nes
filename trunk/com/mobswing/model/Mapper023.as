package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper023 extends MapperDefault
	{
		private	var irq_counter:int = 0;
		private	var irq_latch:int = 0;
		private	var irq_enabled:int = 0;
		private	var regs:Vector.<int> = new Vector.<int>(9);
		private var patch:int = 0xFFFF;

		public function Mapper023()
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
	            switch (address & patch)
	            {
                case 0x8000:
                case 0x8004:
                case 0x8008:
                case 0x800C:
                    if ((regs[8]) != 0)
                    {
                        load8kRomBank(value, 0xC000);
                    }
                    else
                    {
                        load8kRomBank(value, 0x8000);
                    }
                    break;
                case 0x9000:
                    if (value != 0xFF)
                    {
                        value &= 0x03;
                        if (value == 0)
                        {
                            nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                        }
                        else if (value == 1)
                        {
                            nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                        }
                        else if (value == 2)
                        {
                            nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING);
                        }
                        else
                        {
                            nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING2);
                        }
                    }
                    break;
                case 0x9008:
                    regs[8] = value & 0x02;
                    break;
                case 0xA000:
                case 0xA004:
                case 0xA008:
                case 0xA00C:
                    load8kRomBank(value, 0xA000);
                    break;
                case 0xB000:
                    regs[0] = (regs[0] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[0], 0x0000);
                    break;
                case 0xB001:
                case 0xB004:
                    regs[0] = (regs[0] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[0], 0x0000);
                    break;
                case 0xB002:
                case 0xB008:
                    regs[1] = (regs[1] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[1], 0x0400);
                    break;
                case 0xB003:
                case 0xB00C:
                    regs[1] = (regs[1] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[1], 0x0400);
                    break;
                case 0xC000:
                    regs[2] = (regs[2] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[2], 0x0800);
                    break;
                case 0xC001:
                case 0xC004:
                    regs[2] = (regs[2] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[2], 0x0800);
                    break;
                case 0xC002:
                case 0xC008:
                    regs[3] = (regs[3] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[3], 0x0C00);
                    break;
                case 0xC003:
                case 0xC00C:
                    regs[3] = (regs[3] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[3], 0x0C00);
                    break;
                case 0xD000:
                    regs[4] = (regs[4] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[4], 0x1000);
                    break;
                case 0xD001:
                case 0xD004:
                    regs[4] = (regs[4] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[4], 0x1000);
                    break;
                case 0xD002:
                case 0xD008:
                    regs[5] = (regs[5] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[5], 0x1400);
                    break;
                case 0xD003:
                case 0xD00C:
                    regs[5] = (regs[5] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[5], 0x1400);
                    break;
                case 0xE000:
                    regs[6] = (regs[6] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[6], 0x1800);
                    break;
                case 0xE001:
                case 0xE004:
                    regs[6] = (regs[6] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[6], 0x1800);
                    break;
                case 0xE002:
                case 0xE008:
                    regs[7] = (regs[7] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[7], 0x1C00);
                    break;
                case 0xE003:
                case 0xE00C:
                    regs[7] = (regs[7] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[7], 0x1C00);
                    break;
                case 0xF000:
                    irq_latch = (irq_latch & 0xF0) | (value & 0x0F);
                    break;
                case 0xF004:
                    irq_latch = (irq_latch & 0x0F) | ((value & 0x0F) << 4);
                    break;
                case 0xF008:
                    irq_enabled = value & 0x03;
                    if ((irq_enabled & 0x02) != 0)
                    {
                        irq_counter = irq_latch;
                    }
                    break;
                case 0xF00C:
                    irq_enabled = (irq_enabled & 0x01) * 3;
                    break;
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	
	        if (!rom.isValid()) {
	            trace("VRC2: Invalid ROM! Unable to load.");
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
	        if ((irq_enabled & 0x02) != 0)
	        {
	            if (irq_counter == 0xFF) {
	                irq_counter = irq_latch;
	                irq_enabled = (irq_enabled & 0x01) * 3;
	                return 3;
	            }
	            else
	            {
	                irq_counter++;
	            }
	        }
	        return 0;
	    }
	
	    override public	function reset():void
	    {
	        regs[0] = 0;
	        regs[1] = 1;
	        regs[2] = 2;
	        regs[3] = 3;
	        regs[4] = 4;
	        regs[5] = 5;
	        regs[6] = 6;
	        regs[7] = 7;
	        regs[8] = 0;
	
	        // IRQ Settings
	        irq_enabled = 0;
	        irq_latch = 0;
	        irq_counter = 0;
	    }
	}
}