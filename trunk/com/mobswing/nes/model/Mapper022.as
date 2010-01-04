package com.mobswing.nes.model
{
	public class Mapper022 extends MapperDefault
	{
		public function Mapper022()
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
                case 0x9000:
                    value &= 0x03;
                    if (value == 0) {
                        nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                    } else if (value == 1) {
                        nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                    } else if (value == 2) {
                        nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING);
                    } else {
                        nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING2);
                    }
                    break;
                case 0xA000:
                    load8kRomBank(value, 0xA000);
                    break;
                case 0xB000:
                    load1kVromBank((value >> 1), 0x0000);
                    break;
                case 0xB001:
                    load1kVromBank((value >> 1), 0x0400);
                    break;
                case 0xC000:
                    load1kVromBank((value >> 1), 0x0800);
                    break;
                case 0xC001:
                    load1kVromBank((value >> 1), 0x0C00);
                    break;
                case 0xD000:
                    load1kVromBank((value >> 1), 0x1000);
                    break;
                case 0xD001:
                    load1kVromBank((value >> 1), 0x1400);
                    break;
                case 0xE000:
                    load1kVromBank((value >> 1), 0x1800);
                    break;
                case 0xE001:
                    load1kVromBank((value >> 1), 0x1C00);
                    break;
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        //System.out.println("Loading ROM.");
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
	}
}