package com.mobswing.nes.model
{
	public class Mapper068 extends MapperDefault
	{

		private var r1:int, r2:int, r3:int, r4:int;

		public function Mapper068()
		{
			super();
		}
		
		override public	function write(address:int, value:int):void
		{
			if (address < 0x8000)
			{
				super.write(address,value);
				return;
			}
			
			switch ((address>>12)-0x8)
			{
			case 0:
				// Select 2K VROM bank at 0x0000
				load2kVromBank(value,0x0000);
				break;
			case 1:
				// Select 2K VROM bank at 0x0800
				load2kVromBank(value,0x0800);
				break;
			case 2:
				// Select 2K VROM bank at 0x1000
				load2kVromBank(value,0x1000);
				break;
			case 3:
				// Select 2K VROM bank at 0x1800
				load2kVromBank(value,0x1800);
				break;
			case 4:
				// Mirroring.
				r3 = value;
				setMirroring();
				break;
			case 5:
				// Mirroring.
				r4 = value;
				setMirroring();
				break;
			case 6:
				// Mirroring.
				r1 = (value>>4) & 0x1;
				r2 =  value     & 0x3;
				setMirroring();
				break;
			case 7:
				// Select 16K ROM bank at 0x8000
				loadRomBank(value,0x8000);
				break;
			}
			
		}
		
		private	function setMirroring():void
		{
			if (r1 == 0)
			{
				// Normal mirroring modes:
				switch(r2)
				{
				case 0:
					ppu.setMirroring(ROM.HORIZONTAL_MIRRORING);
					break;
				case 1:
					ppu.setMirroring(ROM.VERTICAL_MIRRORING);
					break;
				case 2:
					ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING);
					break;
				case 3:
					ppu.setMirroring(ROM.SINGLESCREEN_MIRRORING2);
					break;
				}
			}
			else
			{
				// Special mirroring (not yet..):
				switch (r2)
				{
				case 0:
					break;
				case 1:
					break;
				case 2:
					break;
				case 3:
					break;
				}
			}
		}
		
		override public	function loadROM(rom:ROM):void
		{
			//System.out.println("Loading ROM.");
		
			if (!rom.isValid())
			{
				//System.out.println("Sunsoft#4: Invalid ROM! Unable to load.");
				return;
			}
			
			// Get number of PRG ROM banks:
			var num_banks:int = rom.getRomBankCount();
			
			// Load PRG-ROM:
			loadRomBank(          0,0x8000);
			loadRomBank(num_banks-1,0xC000);
			
			// Load CHR-ROM:
			loadCHRROM();
			
			// Load Battery RAM (if present):
			loadBatteryRam();
			
			// Do Reset-Interrupt:
			nes.getCpu().requestIrq(CPU.IRQ_RESET);
			
		}
		
		override public	function reset():void
		{
			r1=r2=r3=r4=0;
		}
	}
}