package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	public class Mapper007 extends MapperDefault
	{
		private var currentOffset:int;
		private var currentMirroring:int;
		private var prgrom:Vector.<int>;

		public function Mapper007()
		{
			super();
		}

		override public	function init(nes:Nes):void
		{
			super.init(nes);
			currentOffset    =  0;
			currentMirroring = -1;
			
			// Get ref to ROM:
			var rom:ROM = nes.getRom();
			
			// Read out all PRG rom:
			var bc:int = rom.getRomBankCount();
			prgrom = new Vector.<int>(bc*16384);
			for (var i:int = 0 ; i < bc ; i++)
			{
				var rombank:Vector.<int> = rom.getRomBank(i);
				for (var j:int = 0 ; j < 16384 ; j++)
				{
					prgrom[i*16384+j] = rombank[j];
				}
			}
		}
		
		override public	function load(address:int):int
		{
			if (address < 0x8000)
			{
				// Register read
				return super.load(address);
			}
			else
			{
				// Use the offset to determine where to read from:
				// This is kind of a hack, but it seems to work.
				
				if ((address+currentOffset)>=262144)
				{
					return prgrom[(address+currentOffset)-262144];
				}
				else
				{
					return prgrom[address+currentOffset];
				}
			}
		}

		override public	function write(address:int, value:int):void
		{
			if (address < 0x8000)
			{
				// Let the base mapper take care of it.
				super.write(address,value);
			}
			else
			{
				// Set PRG offset:
				currentOffset = ((value&0xF)-1) << 15;
				
				// Set mirroring:
				if (currentMirroring != (value&0x10))
				{
					currentMirroring = value&0x10;
					if (currentMirroring == 0)
					{
						nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING);
					}
					else
					{
						nes.getPpu().setMirroring(ROM.SINGLESCREEN_MIRRORING2);
					}
				}
			}
		}
		
		override public	function mapperInternalStateLoad(buf:ByteBuffer):void
		{
			super.mapperInternalStateLoad(buf);
			
			// Check version:
			if (buf.readByte()==1)
			{
				currentMirroring = buf.readByte();
				currentOffset    = buf.readInt();
			}
		}
		
		override public	function mapperInternalStateSave(buf:ByteBuffer):void
		{
			super.mapperInternalStateSave(buf);
			
			// Version:
			buf.putByte(1);
			
			// State:
			buf.putByte(currentMirroring);
			buf.putInt (currentOffset   );
		}
		
		override public	function reset():void
		{
			super.reset();
			currentOffset    =  0;
			currentMirroring = -1;
		}
	}
}