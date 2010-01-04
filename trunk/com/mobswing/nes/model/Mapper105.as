package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper105 extends MapperDefault
	{
	    private var irq_counter:int = 0;
	    private	var irq_enabled:Boolean = false;
	    private	var init_state:int = 0;
	    private	var regs:Vector.<int> = new Vector.<int>(4);
	    private var bits:int = 0;
	    private var write_count:int = 0;
	    
		public function Mapper105()
		{
			super();
		}
	
	    override public	function init(nes:Nes):void
	    {
	        super.init(nes);
	        reset();
	    }
	
	    override public	function mapperInternalStateLoad(buf:ByteBuffer):void
	    {
	        super.mapperInternalStateLoad(buf);
	
	        if (buf.readByte() == 1)
	        {
	            irq_counter = buf.readInt();
	            irq_enabled = buf.readBoolean();
	            init_state = buf.readInt();
	        }
	    }
	
		override public	function mapperInternalStateSave(buf:ByteBuffer):void
		{
			super.mapperInternalStateSave(buf);
	
			// Version:
			buf.putByte(1);
	
			// State:
			buf.putInt(irq_counter);
			buf.putBoolean(irq_enabled);
			buf.putInt(init_state);
		}
	
	    override public	function write(address:int, value:int):void
	    {
	        var reg_num:int = (address & 0x7FFF) >> 13;
	
			if (address < 0x8000)
			{
	            super.write(address, value);
	        }
	        else
	        {
	            if ((value & 0x80) != 0)
	            {
	                bits = 0;
	                write_count = 0;
	                if (reg_num == 0)
	                {
	                    regs[reg_num] |= 0x0C;
	                }
	            }
	            else
	            {
	                bits |= (value & 1) << write_count++;
	                if (write_count == 5)
	                {
	                    regs[reg_num] = bits & 0x1F;
	                    bits = write_count = 0;
	                }
	            }
	
	            if ((regs[0] & 0x02) != 0)
	            {
	                if ((regs[0] & 0x01) != 0)
	                {
	                    nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
	                }
	                else
	                {
	                    nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
	                }
	            }
	            else
	            {
	                if ((regs[0] & 0x01) != 0)
	                {
	                    nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING2);
	                }
	                else
	                {
	                    nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING);
	                }
	            }
	
	            switch (init_state)
	            {
                case 0:
                case 1:
                    init_state++;
                    break;
                case 2:
                     {
                        if ((regs[1] & 0x08) != 0)
                        {
                            if ((regs[0] & 0x08) != 0)
                            {
                                if ((regs[0] & 0x04) != 0)
                                {
                                    load8kRomBank((regs[3] & 0x07) * 2 + 16, 0x8000);
                                    load8kRomBank((regs[3] & 0x07) * 2 + 17, 0xA000);
                                    load8kRomBank(30, 0xC000);
                                    load8kRomBank(31, 0xE000);
                                }
                                else
                                {
                                    load8kRomBank(16, 0x8000);
                                    load8kRomBank(17, 0xA000);
                                    load8kRomBank((regs[3] & 0x07) * 2 + 16, 0xC000);
                                    load8kRomBank((regs[3] & 0x07) * 2 + 17, 0xE000);
                                }
                            }
                            else
                            {
                                load8kRomBank((regs[3] & 0x06) * 2 + 16, 0x8000);
                                load8kRomBank((regs[3] & 0x06) * 2 + 17, 0xA000);
                                load8kRomBank((regs[3] & 0x06) * 2 + 18, 0xC000);
                                load8kRomBank((regs[3] & 0x06) * 2 + 19, 0xE000);
                            }
                        }
                        else
                        {
                            load8kRomBank((regs[1] & 0x06) * 2 + 0, 0x8000);
                            load8kRomBank((regs[1] & 0x06) * 2 + 1, 0xA000);
                            load8kRomBank((regs[1] & 0x06) * 2 + 2, 0xC000);
                            load8kRomBank((regs[1] & 0x06) * 2 + 3, 0xE000);
                        }

                        if ((regs[1] & 0x10) != 0)
                        {
                            irq_counter = 0;
                            irq_enabled = false;
                        }
                        else
                        {
                            irq_enabled = true;
                        }
                    }
                    break;
	            }
	        }
	    }
	
	    public	function syncH(scanline:int):int
	    {
	        if (scanline == 0)
	        {
	            if (irq_enabled) {
	                irq_counter += 29781;
	            }
	            if (((irq_counter | 0x21FFFFFF) & 0x3E000000) == 0x3E000000)
	            {
	                return 3;
	            }
	        }
	        return 0;
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        if (!rom.isValid())
	        {
	            //System.out.println("Invalid ROM! Unable to load.");
	            return;
	        }
	
	        // Init:
	        load8kRomBank(0, 0x8000);
	        load8kRomBank(1, 0xA000);
	        load8kRomBank(2, 0xC000);
	        load8kRomBank(3, 0xE000);
	
	        loadCHRROM();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    override public	function reset():void
	    {
	        regs[0] = 0x0C;
	        regs[1] = 0x00;
	        regs[2] = 0x00;
	        regs[3] = 0x10;
	
	        bits = 0;
	        write_count = 0;
	
	        irq_enabled = false;
	        irq_counter = 0;
	        init_state = 0;
	    }
	}
}