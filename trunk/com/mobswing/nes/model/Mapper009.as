package com.mobswing.model
{
	public class Mapper009 extends MapperDefault
	{
		private var latchLo		:int;
	    private var latchHi		:int;
	    private var latchLoVal1	:int;
	    private var latchLoVal2	:int;
	    private var latchHiVal1	:int;
	    private var latchHiVal2	:int;
			
		public function Mapper009()
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
	            // Handle normally.
	            super.write(address, value);
	        }
	        else
	        {
	            // MMC2 write.
	            value &= 0xFF;
	            address &= 0xF000;
	            switch (address >> 12)
	            {
                case 0xA:
                    // Select 8k ROM bank at 0x8000
                    load8kRomBank(value, 0x8000);
                    return;
                case 0xB:
                    // Select 4k VROM bank at 0x0000, $FD mode
                    latchLoVal1 = value;
                    if (latchLo == 0xFD)
                    {
                        loadVromBank(value, 0x0000);
                    }
                    return;
                case 0xC:
                    // Select 4k VROM bank at 0x0000, $FE mode
                    latchLoVal2 = value;
                    if (latchLo == 0xFE)
                    {
                        loadVromBank(value, 0x0000);
                    }
                    return;
                case 0xD:
                    // Select 4k VROM bank at 0x1000, $FD mode
                    latchHiVal1 = value;
                    if (latchHi == 0xFD)
                    {
                        loadVromBank(value, 0x1000);
                    }
                    return;
                case 0xE:
                    // Select 4k VROM bank at 0x1000, $FE mode
                    latchHiVal2 = value;
                    if (latchHi == 0xFE)
                    {
                        loadVromBank(value, 0x1000);
                    }
                    return;
                case 0xF:
                    // Select mirroring
                    if ((value & 0x1) == 0)
                    {
                        // Vertical mirroring
                        nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                    }
                    else
                    {
                        // Horizontal mirroring
                        nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                    }
                    return;
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
	    {
	        //System.out.println("Loading ROM.");
	
	        if (!rom.isValid()) 
	        {
	            //System.out.println("MMC2: Invalid ROM! Unable to load.");
	            return;
	        }
	
	        // Get number of 8K banks:
	        var num_8k_banks:int = rom.getRomBankCount() * 2;
	
	        // Load PRG-ROM:
	        load8kRomBank(0, 0x8000);
	        load8kRomBank(num_8k_banks - 3, 0xA000);
	        load8kRomBank(num_8k_banks - 2, 0xC000);
	        load8kRomBank(num_8k_banks - 1, 0xE000);
	
	        // Load CHR-ROM:
	        loadCHRROM();
	
	        // Load Battery RAM (if present):
	        loadBatteryRam();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    override public	function latchAccess(address:int):void
	    {
	        if ((address & 0x1FF0) == 0x0FD0 && latchLo != 0xFD)
	        {
	            // Set $FD mode
	            loadVromBank(latchLoVal1, 0x0000);
	            latchLo = 0xFD;
	        //System.out.println("LO FD");
	        }
	        else if ((address & 0x1FF0) == 0x0FE0 && latchLo != 0xFE)
	        {
	            // Set $FE mode
	            loadVromBank(latchLoVal2, 0x0000);
	            latchLo = 0xFE;
	        //System.out.println("LO FE");
	        }
	        else if ((address & 0x1FF0) == 0x1FD0 && latchHi != 0xFD)
	        {
	            // Set $FD mode
	            loadVromBank(latchHiVal1, 0x1000);
	            latchHi = 0xFD;
	        //System.out.println("HI FD");
	        }
	        else if ((address & 0x1FF0) == 0x1FE0 && latchHi != 0xFE)
	        {
	            // Set $FE mode
	            loadVromBank(latchHiVal2, 0x1000);
	            latchHi = 0xFE;
	        //System.out.println("HI FE");
	        }
	    }
	
	    override public	function mapperInternalStateLoad(buf:ByteBuffer):void
	    {
	        super.mapperInternalStateLoad(buf);
	
	        // Check version:
	        if (buf.readByte() == 1)
	        {
	            latchLo = buf.readByte();
	            latchHi = buf.readByte();
	            latchLoVal1 = buf.readByte();
	            latchLoVal2 = buf.readByte();
	            latchHiVal1 = buf.readByte();
	            latchHiVal2 = buf.readByte();
	        }
	    }
	
	    override public	function mapperInternalStateSave(buf:ByteBuffer):void
	    {
	        super.mapperInternalStateSave(buf);
	
	        // Version:
	        buf.putByte(1);
	
	        // State:
	        buf.putByte(latchLo);
	        buf.putByte(latchHi);
	        buf.putByte(latchLoVal1);
	        buf.putByte(latchLoVal2);
	        buf.putByte(latchHiVal1);
	        buf.putByte(latchHiVal2);
	    }
	
	    override public	function reset():void
	    {
	        // Set latch to $FE mode:
	        latchLo = 0xFE;
	        latchHi = 0xFE;
	        latchLoVal1 = 0;
	        latchLoVal2 = 4;
	        latchHiVal1 = 0;
	        latchHiVal2 = 0;
	    }
	}
}