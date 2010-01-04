package com.mobswing.nes.model
{
	public class Mapper048 extends MapperDefault
	{
	    private	var irq_counter:int = 0;
	    private var irq_enabled:Boolean = false;

		public	function Mapper048()
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
	            switch (address)
	            {
                case 0x8000:
                    load8kRomBank(value, 0x8000);
                    break;
                case 0x8001:
                    load8kRomBank(value, 0xA000);
                    break;
                case 0x8002:
                    load2kVromBank(value * 2, 0x0000);
                    break;
                case 0x8003:
                    load2kVromBank(value * 2, 0x0800);
                    break;
                case 0xA000:
                    load1kVromBank(value, 0x1000);
                    break;
                case 0xA001:
                    load1kVromBank(value, 0x1400);
                    break;
                case 0xA002:
                    load1kVromBank(value, 0x1800);
                    break;
                case 0xA003:
                    load1kVromBank(value, 0x1C00);
                    break;
                case 0xC000:
                    irq_counter = value;
                    break;
                case 0xC001:
                case 0xC002:
                case 0xE001:
                case 0xE002:
                    irq_enabled = (value != 0);
                    break;
                case 0xE000:
                    if ((value & 0x40) != 0)
                    {
                        nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                    }
                    else
                    {
                        nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                    }
                    break;
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        if (!rom.isValid())
	        {
	            trace("VRC4: Invalid ROM! Unable to load.");
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
	
	        // Load Battery RAM (if present):
	        loadBatteryRam();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    public	function syncH(scanline:int):int
	    {
	        if (irq_enabled)
	        {
	            if ((ppu.scanline & 0x18) != 00)
	            {
	                if (scanline >= 0 && scanline <= 239)
	                {
	                    if (irq_counter == 0)
	                    {
	                        irq_counter = 0;
	                        irq_enabled = false;
	                        return 3;
	                    }
	                    else
	                    {
	                        irq_counter++;
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