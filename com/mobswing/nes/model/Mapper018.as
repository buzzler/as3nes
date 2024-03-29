package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper018 extends MapperDefault
	{
	    private	var irq_counter:int = 0;
	    private	var irq_latch:int = 0;
	    private	var irq_enabled:Boolean = false;
	    private	var regs:Vector.<int> = new Vector.<int>(11);
	    private var num_8k_banks:int;
	    private var patch:int = 0;
		
		public function Mapper018()
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
	            irq_latch = buf.readInt();
	            irq_enabled = buf.readBoolean();
	        }
	    }
	
	    override public	function mapperInternalStateSave(buf:ByteBuffer):void
	    {
	        super.mapperInternalStateLoad(buf);
	
	        // Version:
	        buf.putByte( 1);
	
	        buf.putInt(irq_counter);
	        buf.putInt(irq_latch);
	        buf.putBoolean(irq_enabled);
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
                    regs[0] = (regs[0] & 0xF0) | (value & 0x0F);
                    load8kRomBank(regs[0], 0x8000);
                    break;
                case 0x8001:
                    regs[0] = (regs[0] & 0x0F) | ((value & 0x0F) << 4);
                    load8kRomBank(regs[0], 0x8000);
                    break;
                case 0x8002:
                    regs[1] = (regs[1] & 0xF0) | (value & 0x0F);
                    load8kRomBank(regs[1], 0xA000);
                    break;
                case 0x8003:
                    regs[1] = (regs[1] & 0x0F) | ((value & 0x0F) << 4);
                    load8kRomBank(regs[1], 0xA000);
                    break;
                case 0x9000:
                    regs[2] = (regs[2] & 0xF0) | (value & 0x0F);
                    load8kRomBank(regs[2], 0xC000);
                    break;
                case 0x9001:
                    regs[2] = (regs[2] & 0x0F) | ((value & 0x0F) << 4);
                    load8kRomBank(regs[2], 0xC000);
                    break;
                case 0xA000:
                    regs[3] = (regs[3] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[3], 0x0000);
                    break;
                case 0xA001:
                    regs[3] = (regs[3] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[3], 0x0000);
                    break;
                case 0xA002:
                    regs[4] = (regs[4] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[4], 0x0400);
                    break;
                case 0xA003:
                    regs[4] = (regs[4] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[4], 0x0400);
                    break;
                case 0xB000:
                    regs[5] = (regs[5] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[5], 0x0800);
                    break;
                case 0xB001:
                    regs[5] = (regs[5] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[5], 0x0800);
                    break;
                case 0xB002:
                    regs[6] = (regs[6] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[6], 0x0C00);
                    break;
                case 0xB003:
                    regs[6] = (regs[6] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[6], 0x0C00);
                    break;
                case 0xC000:
                    regs[7] = (regs[7] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[7], 0x1000);
                    break;
                case 0xC001:
                    regs[7] = (regs[7] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[7], 0x1000);
                    break;
                case 0xC002:
                    regs[8] = (regs[8] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[8], 0x1400);
                    break;
                case 0xC003:
                    regs[8] = (regs[8] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[8], 0x1400);
                    break;
                case 0xD000:
                    regs[9] = (regs[9] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[9], 0x1800);
                    break;
                case 0xD001:
                    regs[9] = (regs[9] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[9], 0x1800);
                    break;
                case 0xD002:
                    regs[10] = (regs[10] & 0xF0) | (value & 0x0F);
                    load1kVromBank(regs[10], 0x1C00);
                    break;
                case 0xD003:
                    regs[10] = (regs[10] & 0x0F) | ((value & 0x0F) << 4);
                    load1kVromBank(regs[10], 0x1C00);
                    break;
                case 0xE000:
                    irq_latch = (irq_latch & 0xFFF0) | (value & 0x0F);
                    break;
                case 0xE001:
                    irq_latch = (irq_latch & 0xFF0F) | ((value & 0x0F) << 4);
                    break;
                case 0xE002:
                    irq_latch = (irq_latch & 0xF0FF) | ((value & 0x0F) << 8);
                    break;
                case 0xE003:
                    irq_latch = (irq_latch & 0x0FFF) | ((value & 0x0F) << 12);
                    break;
                case 0xF000:
                    irq_counter = irq_latch;
                    break;
                case 0xF001:
                    irq_enabled = (value & 0x01) != 0;
                    break;
                case 0xF002:
                    value &= 0x03;

                    if (value == 0)
                    {
                        nes.getPpu().setMirroring(ROM.HORIZONTAL_MIRRORING);
                    }
                    else if (value == 1)
                    {
                        nes.getPpu().setMirroring(ROM.VERTICAL_MIRRORING);
                    }
                    else
                    {
                        nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING);
                    }
                    break;
	            }
	        }
	    }
	
	    override public	function loadROM(rom:ROM):void
		{
	        //System.out.println("Loading ROM.");
	
	        if (!rom.isValid())
	        {
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
	
	        loadBatteryRam();
	
	        // Do Reset-Interrupt:
	        nes.getCpu().requestIrq(CPU.IRQ_RESET);
	    }
	
	    public	function syncH(scanline:int):int
	    {
	        if (irq_enabled)
	        {
	            if (irq_counter <= 113)
	            {
	                irq_counter = (patch == 1) ? 114 : 0;
	                irq_enabled = false;
	                return 3;
	            }
	            else
	            {
	                irq_counter -= 113;
	            }
	        }
	        return 0;
	    }
	
	    override public	function setCRC(crc:Number):void
	    {
	        patch = 0;
	
/* 	
	        if (crc == 253471719l)
	        {
	            // Jajamaru Gekimaden - Maboroshi no Kinmajou (J)
	            patch = 1;
	            trace("Patched CRC:" + crc);
	        }
 */
	    }
	
	    override public	function reset():void
	    {
	        regs[0] = 0;
	        regs[1] = 1;
	        regs[2] = num_8k_banks - 2;
	        regs[3] = num_8k_banks - 1;
	        regs[4] = 0;
	        regs[5] = 0;
	        regs[6] = 0;
	        regs[7] = 0;
	        regs[8] = 0;
	        regs[9] = 0;
	        regs[10] = 0;
	
	        // IRQ Settings
	        irq_enabled = false;
	        irq_latch = 0;
	        irq_counter = 0;
	    }
	}
}