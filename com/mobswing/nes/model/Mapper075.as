package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper075 extends MapperDefault
	{
	    private var regs:Vector.<int> = new Vector.<int>(2);

		public function Mapper075()
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
	            super.write(address, value);
	        }
	        else
	        {
	            switch (address & 0xF000)
	            {
                case 0x8000:
                    load8kRomBank(value, 0x8000);
                    break;
                case 0x9000:
                    if ((value & 0x01) != 0)
                    {
                        nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                    }
                    else
                    {
                        nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                    }

                    regs[0] = (regs[0] & 0x0F) | ((value & 0x02) << 3);
                    loadVromBank(regs[0], 0x0000);

                    regs[1] = (regs[1] & 0x0F) | ((value & 0x04) << 2);
                    loadVromBank(regs[1], 0x1000);
                    break;
                case 0xA000:
                    load8kRomBank(value, 0xA000);
                    break;
                case 0xC000:
                    load8kRomBank(value, 0xC000);
                    break;
                case 0xE000:
                    regs[0] = (regs[0] & 0x10) | (value & 0x0F);
                    loadVromBank(regs[0], 0x0000);
                    break;
                case 0xF000:
                    regs[1] = (regs[1] & 0x10) | (value & 0x0F);
                    loadVromBank(regs[1], 0x1000);
                    break;
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
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
	
	    override public	function reset():void
	    {
	        regs[0] = 0;
	        regs[1] = 1;
	    }
	}
}