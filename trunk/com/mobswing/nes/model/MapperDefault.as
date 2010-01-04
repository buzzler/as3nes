package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	import com.mobswing.nes.control.GameGenie;
	import com.mobswing.nes.control.IInputHandler;
	import com.mobswing.nes.control.KbInputHandler;
	
	public class MapperDefault implements IMemoryMapper
	{
		public	var nes				:Nes;
		public	var cpuMem			:Memory;
		public	var ppuMem			:Memory;
		public	var cpuMemArray		:Vector.<int>;
		public	var rom				:ROM;
		public	var cpu				:CPU;
		public	var ppu				:PPU;
		public	var cpuMemSize		:int;
		public	var joy1StrobeState	:int;
		public	var joy2StrobeState	:int;
		public	var joypadLastWrite	:int;
		public	var mousePressed	:Boolean;
		public	var gameGenieActive	:Boolean;
		public	var mouseX			:int;
		public	var mouseY			:int;
		private	var tmp				:int;
		private var crc				:Number;
		
		public function MapperDefault()
		{
		}

		public function init(nes:Nes):void
		{
			this.nes = nes;
			this.cpuMem = this.nes.getCpuMemory();
			this.cpuMemArray = this.cpuMem.mem;
			this.ppuMem = this.nes.getPpuMemory();
			this.rom = this.nes.getRom();
			this.cpu = this.nes.getCpu();
			this.ppu = this.nes.getPpu();
			
			this.cpuMemSize = this.cpuMem.getMemSize();
			this.joypadLastWrite = -1;
		}
		
		public function write(address:int, value:int):void
		{
			if (address < 0x2000)
			{
				this.cpuMem.write(address & 0x7FF, value);
			}
			else if (address > 0x4017)
			{
				this.cpuMem.write(address, value);
				if (address >= 0x6000 && address < 0x8000)
				{
					if (this.rom != null)
					{
						this.rom.writeBatteryRam(address, value);
					}
				}
			}
			else if (address > 0x2007 && address < 0x4000)
			{
				regWrite(0x2000 + (address & 0x7), value);
			}
			else
			{
				regWrite(address, value);
			}
		}
		
		public	function writelow(address:int, value:int):void
		{
			if (address < 0x2000)
				this.cpuMem.write(address & 0x7FF, value);
			else if (address > 0x4017)
				this.cpuMem.write(address, value);
			else if (address > 0x2007 && address < 0x4000)
				regWrite(0x2000 + (address & 0x7), value);
			else
				regWrite(address, value);
		}
		
		public function load(address:int):int
		{
			if (this.gameGenieActive)
			{
				if (this.nes.gameGenie.addressMatch[address])
				{
					this.tmp = this.nes.gameGenie.getCodeIndex(address);
					
					if (this.nes.gameGenie.getCodeType(this.tmp) == GameGenie.TYPE_6CHAR)
					{
						return this.nes.gameGenie.getCodeValue(this.tmp);
					}
					else
					{
						if (this.cpuMem.load(address) == this.nes.gameGenie.getCodeCompare(this.tmp))
						{
							return this.nes.gameGenie.getCodeValue(this.tmp);
						}
					}
				}
			}
			
			address &= 0xFFFF;
			if (address > 0x4017)
			{
				return this.cpuMemArray[address];
			}
			else if (address >= 0x2000)
			{
				return regLoad(address);
			}
			else
			{
				return this.cpuMemArray[address & 0x7FF];
			}
		}
		
		public	function regLoad(address:int):int
		{
			switch (address >> 12)
			{
			case 0:
				break;
			case 1:
				break;
			case 2:
			case 3:
				// PPU resister
				switch (address & 0x7)
				{
				case 0x0:
					return this.cpuMem.mem[0x2000];
				case 0x1:
					return this.cpuMem.mem[0x2001];
				case 0x2:
					return this.ppu.readStatusRegister();
				case 0x3:
					return 0;
				case 0x4:
					return this.ppu.sramLoad();
				case 0x5:
					return 0;
				case 0x6:
					return 0;
				case 0x7:
					return this.ppu.vramLoad();
				}
				break;
			case 4:
				switch (address - 0x4015)
				{
				case 0:
					return this.nes.getPapu().readReg(address);
				case 1:
					return joy1Read();
				case 2:
					if (this.mousePressed && this.nes.ppu != null && this.nes.ppu.buffer != null)
					{
						var sx:int = Math.max(0, this.mouseX-4);
						var ex:int = Math.min(Globals.WIDTH, this.mouseX+4);
						var sy:int = Math.max(0, this.mouseY-4);
						var ey:int = Math.min(Globals.HEIGHT, this.mouseY+4);
						var w:int = 0;
						
						for (var y:int = sy ; y < ey ; y++)
						{
							for (var x:int = sx ; x < ex ; x++)
							{
								if ((this.nes.ppu.buffer[(y << 8) + x] & 0xFFFFFF) == 0xFFFFFF)
								{
									w = 0x1 << 3;
									break;
								}
							}
						}
						
						w != (this.mousePressed ? (0x1<<4):0);
						return int(joy2Read() | w);
					}
					else
					{
						return joy2Read();
					}
				}
				break;
			}
			return 0;
		}
		
		public	function regWrite(address:int, value:int):void
		{
			switch (address)
			{
			case 0x2000:
				this.cpuMem.write(address, value);
				this.ppu.updateControlReg1(value);
				break;
			case 0x2001:
				this.cpuMem.write(address, value);
				this.ppu.updateControlReg2(value);
				break;
			case 0x2003:
				this.ppu.writeSRAMAddress(value);
				break;
			case 0x2004:
				this.ppu.sramWrite(value);
				break;
			case 0x2005:
				this.ppu.scrollWrite(value);
				break;
			case 0x2006:
				this.ppu.writeVRAMAddress(value);
				break;
			case 0x2007:
				this.ppu.vramWrite(value);
				break;
			case 0x4014:
				this.ppu.sramDMA(value);
				break;
			case 0x4015:
				this.nes.getPapu().writeReg(address, value);
				break;
			case 0x4016:
				if ((this.joypadLastWrite==1) && (value ==0))
				{
					this.joy1StrobeState = 0;
					this.joy2StrobeState = 0;
				}
				this.joypadLastWrite = value;
				break;
			case 0x4017:
				this.nes.getPapu().writeReg(address, value);
				break;
			default:
				if (address >= 0x4000 && address <= 0x4017)
					this.nes.getPapu().writeReg(address, value);
				break;
			}
		}
		
		/* public	function joy1Read():int
		{
 			var ih:IInputHandler = this.nes.getGui().getJoy1();
			var ret:int;
			
			switch (this.joy1StrobeState)
			{
			case 0:
				ret = ih.getKeyState(KbInputHandler.KEY_A);
				break;
			case 1:
				ret = ih.getKeyState(KbInputHandler.KEY_B);
				break;
			case 2:
				ret = ih.getKeyState(KbInputHandler.KEY_SELECT);
				break;
			case 3:
				ret = ih.getKeyState(KbInputHandler.KEY_START);
				break;
			case 4:
				ret = ih.getKeyState(KbInputHandler.KEY_UP);
				break;
			case 5:
				ret = ih.getKeyState(KbInputHandler.KEY_DOWN);
				break;
			case 6:
				ret = ih.getKeyState(KbInputHandler.KEY_LEFT);
				break;
			case 7:
				ret = ih.getKeyState(KbInputHandler.KEY_RIGHT);
				break;
			case 19:
				ret = 1;
				break;
			default:
				ret = 0;
				break;
			}
			this.joy1StrobeState = (this.joy1StrobeState + 1) % 24;
			return ret;
		} */
		public	function joy1Read():int
		{
 			var ih:IInputHandler = this.nes.getGui().getJoy1();
 			var sh:int = this.joy1StrobeState;

 			this.joy1StrobeState = (this.joy1StrobeState + 1) % 24;
			
			switch (sh)
			{
			case 0:
				return ih.getKeyState(KbInputHandler.KEY_A);
			case 1:
				return ih.getKeyState(KbInputHandler.KEY_B);
			case 2:
				return ih.getKeyState(KbInputHandler.KEY_SELECT);
			case 3:
				return ih.getKeyState(KbInputHandler.KEY_START);
			case 4:
				return ih.getKeyState(KbInputHandler.KEY_UP);
			case 5:
				return ih.getKeyState(KbInputHandler.KEY_DOWN);
			case 6:
				return ih.getKeyState(KbInputHandler.KEY_LEFT);
			case 7:
				return ih.getKeyState(KbInputHandler.KEY_RIGHT);
			case 19:
				return 1;
			default:
				return 0;
			}
		}
		
		public	function joy2Read():int
		{
			var ih:IInputHandler = this.nes.getGui().getJoy2();
			var sh:int = this.joy2StrobeState;
			
			this.joy2StrobeState = (this.joy2StrobeState + 1) % 24;
			
			switch (sh)
			{
			case 0:
				return ih.getKeyState(KbInputHandler.KEY_A);
			case 1:
				return ih.getKeyState(KbInputHandler.KEY_B);
			case 2:
				return ih.getKeyState(KbInputHandler.KEY_SELECT);
			case 3:
				return ih.getKeyState(KbInputHandler.KEY_START);
			case 4:
				return ih.getKeyState(KbInputHandler.KEY_UP);
			case 5:
				return ih.getKeyState(KbInputHandler.KEY_DOWN);
			case 6:
				return ih.getKeyState(KbInputHandler.KEY_LEFT);
			case 7:
				return ih.getKeyState(KbInputHandler.KEY_RIGHT);
			case 18:
				return 1;
			default:
				return 0;
			}
		}
		
		public	function loadROM(rom:ROM):void
		{
			if (!this.rom.isValid() || this.rom.getRomBankCount() < 1)
			{
				trace("NoMapper: Invalid ROM! Unable to load.");
				return;
			}
			
			loadPRGROM();
			loadCHRROM();
			loadBatteryRam();
			this.nes.getCpu().requestIrq(CPU.IRQ_RESET);
		}
		
		public	function loadPRGROM():void
		{
			if (this.rom.getRomBankCount() > 1)
			{
				loadRomBank(0, 0x8000);
				loadRomBank(1, 0xC000);
			}
			else
			{
				loadRomBank(0, 0x8000);
				loadRomBank(0, 0xC000);
			}
		}
		
		public	function loadCHRROM():void
		{
			if (this.rom.getVromBankCount() > 0)
			{
				if (this.rom.getVromBankCount() == 1)
				{
					loadVromBank(0, 0x0000);
					loadVromBank(0, 0x1000);
				}
				else
				{
					loadVromBank(0, 0x0000);
					loadVromBank(1, 0x1000);
				}
			}
			else
			{
				trace("There aren't any CHR-ROM banks..");
			}
		}
		
		public	function loadBatteryRam():void
		{
			if (this.rom.batteryRam)
			{
				var ram:Vector.<int> = this.rom.getBatteryRam();
				if (ram != null && ram.length == 0x2000)
				{
					for (var i:int = 0 ; i < 0x2000 ; i++)
					{
						this.nes.cpuMem.mem[0x6000 + i] = ram[i];
					}
				}
			}
		}
		
		protected	function loadRomBank(bank:int, address:int):void
		{
			bank %= this.rom.getRomBankCount();
			var data:Vector.<int> = this.rom.getRomBank(bank);
			
			for (var i:int = 0 ; i < 16384 ; i++)
			{
				this.cpuMem.mem[address + i] = rom.getRomBank(bank)[i];
			}
		}
		
		protected	function loadVromBank(bank:int, address:int):void
		{
			if (this.rom.getVromBankCount() == 0)	return;
			
			this.ppu.triggerRendering();
			
			var i:int;
			var vromBank:Vector.<int> = this.rom.getVromBank(bank % this.rom.getVromBankCount());
			for (i = 0 ; i< 4096 ; i++)
			{
				this.nes.ppuMem.mem[address + i] = vromBank[i];
			}
			var j:int = address >> 4;
			var vromTile:Vector.<Tile> = this.rom.getVromBankTiles(bank % this.rom.getVromBankCount());
			for (i = 0 ; i < 256 ; i++)
			{
				this.ppu.ptTile[j + i] = vromTile[i];
			}
		}
		
		protected	function load32kRomBank(bank:int, address:int):void
		{
			loadRomBank((bank * 2) % this.rom.getRomBankCount(), address);
			loadRomBank((bank * 2 + 1) % this.rom.getRomBankCount(), address + 16384);
		}
		
		protected	function load8kVromBank(bank4kStart:int, address:int):void
		{
			if (this.rom.getVromBankCount() == 0) return;
			this.ppu.triggerRendering();
			
			loadVromBank(bank4kStart % this.rom.getVromBankCount(), address);
			loadVromBank((bank4kStart + 1) % this.rom.getVromBankCount(), address + 4096);
		}
		
		protected	function load1kVromBank(bank1k:int, address:int):void
		{
			if (this.rom.getVromBankCount() == 0) return;
			this.ppu.triggerRendering();
			
			var bank4k:int = (bank1k / 4) % this.rom.getVromBankCount();
			var bankoffset:int = (bank1k % 4) * 1024;
			var i:int;
			var vb:Vector.<int> = this.rom.getVromBank(bank4k);
			for (i = 0 ; i < 1024 ; i++)
			{
				this.nes.ppuMem.mem[bankoffset + i] = vb[i];
			}
			
			//update Tiles
			var vromTile:Vector.<Tile> = this.rom.getVromBankTiles(bank4k);
			var baseIndex:int = address >> 4;
			for (i = 0 ; i < 64 ; i++)
			{
				this.ppu.ptTile[baseIndex + i] = vromTile[((bank4k % 4) << 6) + i];
			}
		}
		
		protected	function load2kVromBank(bank2k:int, address:int):void
		{
			if (this.rom.getVromBankCount() == 0) return;
			this.ppu.triggerRendering();
			
			var bank4k:int = (bank2k / 2) % this.rom.getVromBankCount();
			var bankoffset:int = (bank2k % 2) * 2048;
			var i:int;
			var vb:Vector.<int> = this.rom.getVromBank(bank4k);
			for (i = 0 ; i < 2048 ; i++)
			{
				this.nes.ppuMem.mem[address + i] = vb[bankoffset + i];
			}
			
			//update Tiles
			var vromTile:Vector.<Tile> = this.rom.getVromBankTiles(bank4k);
			var baseIndex:int = address >> 4;
			for (i = 0 ; i < 128 ; i++)
			{
				this.ppu.ptTile[baseIndex + i] = vromTile[((bank2k % 2) << 7) + i];
			}
		}
		
		protected	function load8kRomBank(bank8k:int, address:int):void
		{
			var bank16k:int = (bank8k / 2) % this.rom.getRomBankCount();
			var offset:int = (bank8k % 2) * 8192;
			
			var bank:Vector.<int> = this.rom.getRomBank(bank16k);
			this.cpuMem.writeArrayAt(address, bank, offset, 8192);
		}
		
		public	function clockIrqCounter():void
		{
		}
		
		public	function latchAccess(address:int):void
		{
		}
		
		public	function syncV():int
		{
			return 0;
		}
		
		public	function syncVAt(scanline:int):int{
			return 0;
		}
		
		public	function setCRC(crc:Number):void
		{
		}
		
		public	function reset():void
		{
			this.mousePressed = false;
			this.joy1StrobeState = 0;
			this.joy2StrobeState = 0;
			this.joypadLastWrite = 0;
		}

		public	function setGameGenieState(value:Boolean):void
		{
			this.gameGenieActive = value;
		}
		
		public	function getGameGenieState():Boolean
		{
			return this.gameGenieActive;
		} 
		
		public	function destroy():void
		{
			this.nes = null;
			this.cpuMem = null;
			this.ppuMem = null;
			this.rom = null;
			this.cpu = null;
			this.ppu = null;
		}
		
		public	function stateLoad(buf:ByteBuffer):void
		{
			// check version
			if (buf.readByte() == 1)
			{
				this.joy1StrobeState = buf.readInt();
				this.joy2StrobeState = buf.readInt();
				this.joypadLastWrite = buf.readInt();
				
				mapperInternalStateLoad(buf);
			}
		}
		
		public	function stateSave(buf:ByteBuffer):void
		{
			buf.putByte(1);
			
			buf.putInt(this.joy1StrobeState);
			buf.putInt(this.joy2StrobeState);
			buf.putInt(this.joypadLastWrite);
			
			mapperInternalStateSave(buf);
		}
		
		public	function setMouseState(pressed:Boolean, x:int, y:int):void
		{
			this.mousePressed = pressed;
			this.mouseX = x;
			this.mouseY = y;
		}
		
		public	function mapperInternalStateLoad(buf:ByteBuffer):void
		{
			buf.putByte(this.joy1StrobeState);
			buf.putByte(this.joy2StrobeState);
			buf.putByte(this.joypadLastWrite);
		}
		
		public	function mapperInternalStateSave(buf:ByteBuffer):void
		{
			this.joy1StrobeState = buf.readByte();
			this.joy2StrobeState = buf.readByte();
			this.joypadLastWrite = buf.readByte();
		}
	}
}