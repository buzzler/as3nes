
package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	import com.mobswing.view.BufferView;

	public class PPU
	{
		private	var nes		:Nes;
		private	var timer	:HiResTimer;
		private	var ppuMem	:Memory;
		private	var sprMem	:Memory;

		private var showSpr0Hit		:Boolean = false;
		public	var showSoundBuffer	:Boolean = false;
		private var clipToTvSize	:Boolean = true;

		public	var f_nmiOnVblank	:int;
		public	var f_spriteSize	:int;
		public	var f_bgPatternTable:int;
		public	var f_spPatternTable:int;
		public	var f_addrInc		:int;
		public	var f_nTblAddress	:int;

		public	var f_color			:int;
		public	var f_spVisibility	:int;
		public	var f_bgVisibility	:int;
		public	var f_spClipping	:int;
		public	var f_bgClipping	:int;
		public	var f_dispType		:int;

		public	var STATUS_VRAMWRITE	:int = 4;
		public	var STATUS_SLSPRITECOUNT:int = 5;
		public	var STATUS_SPRITE0HIT	:int = 6;
		public	var STATUS_VBLANK		:int = 7;

		private var vramAddress				:int;
		private var vramTmpAddress			:int;
		private var vramBufferedReadValue	:int;
		private var firstWrite				:Boolean = true;

		private var vramMirrorTable	:Vector.<int>;
		private var i				:int;
		private var sramAddress		:int;

		private var cntFV	:int;
		private var cntV	:int;
		private var cntH	:int;
		private var cntVT	:int;
		private var cntHT	:int;

		private var regFV	:int;
		private var regV	:int;
		private var regH	:int;
		private var regVT	:int;
		private var regHT	:int;
		private var regFH	:int;
		private var regS	:int;

		private var vblankAdd:int = 0;

		public	var curX				:int;
		public	var scanline			:int;
		public	var lastRenderedScanline:int;
		public	var mapperIrqCounter	:int;

		public	var sprX		:Vector.<int>;
		public	var sprY		:Vector.<int>;
		public	var sprTile		:Vector.<int>;
		public	var sprCol		:Vector.<int>;
		public	var vertFlip	:Vector.<Boolean>;
		public	var horiFlip	:Vector.<Boolean>;
		public	var bgPriority	:Vector.<Boolean>;
		public	var spr0HitX	:int;
		public	var spr0HitY	:int;
		private	var hitSpr0		:Boolean;
		public	var ptTile		:Vector.<Tile>;

		private	var ntable1			:Vector.<int> = new Vector.<int>(4);
		private var nameTable		:Vector.<NameTable>;
		private	var currentMirroring:int = -1;

		private var sprPalette:Vector.<int> = new Vector.<int>(16);
		private var imgPalette:Vector.<int> = new Vector.<int>(16);

		private var scanlineAlreadyRendered	:Boolean;
		private	var requestEndFrame			:Boolean;
		private var nmiOk					:Boolean;
		private var nmiCounter				:int;
		private var tmp						:int;
		private var dummyCycleToggle		:Boolean;

		private var address:int, b1:int, b2:int;

		private var attrib			:Vector.<int> = new Vector.<int>(32);
		private var bgbuffer		:Vector.<int> = new Vector.<int>(256*240);
		private var pixrendered		:Vector.<int> = new Vector.<int>(256*240);
		private var spr0dummybuffer	:Vector.<int> = new Vector.<int>(256*240);
		private var dummyPixPriTable:Vector.<int> = new Vector.<int>(256*240);
		private var oldFrame		:Vector.<int> = new Vector.<int>(256*240);
		public	var buffer			:Vector.<int>;
		private var tpix			:Vector.<int>;

		public	var scanlineChanged	:Vector.<Boolean> = new Vector.<Boolean>(240);
		public	var requestRenderAll:Boolean = false;
		private var validTileData	:Boolean;
		private var att				:int;

		private var scantile		:Vector.<Tile> = new Vector.<Tile>(32);
		private var t				:Tile;

		private var curNt		:int;
		private var destIndex	:int;
		private var tile		:int;
		private var col			:int;
		private var baseTile	:int;
		private var tscanoffset	:int;
		private	var x:int, y:int, sx:int;
		private var si:int, ei:int;
		private var srcy1:int, srcy2:int;
		private var bufferSize:int, available:int, scale:int;

		public	var cycles:int = 0;

		public function PPU(nes:Nes)
		{
			this.nes = nes;
		}

		public	function init():void
		{
			this.ppuMem = this.nes.getPpuMemory();
			this.sprMem = this.nes.getSprMemory();

			updateControlReg1(0);
			updateControlReg2(0);

			this.scanline = 0;
			this.timer = this.nes.getGui().getTimer();

			this.sprX		= new Vector.<int>(64);
			this.sprY		= new Vector.<int>(64);
			this.sprTile	= new Vector.<int>(64);
			this.sprCol		= new Vector.<int>(64);
			this.vertFlip	= new Vector.<Boolean>(64);
			this.horiFlip	= new Vector.<Boolean>(64);
			this.bgPriority	= new Vector.<Boolean>(64);

			var i:int;
			if (this.ptTile == null)
			{
				this.ptTile = new Vector.<Tile>(512);
				for (i = 0 ; i < 512 ; i++)
				{
					this.ptTile[i] = new Tile();
				}
			}

			this.nameTable = new Vector.<NameTable>(4);
			for (i = 0 ; i < 4 ; i++)
			{
				this.nameTable[i] = new NameTable(32,32,"Nt"+i);
			}

			this.vramMirrorTable = new Vector.<int>(0x8000);
			for (i = 0 ; i < 0x8000 ; i++)
			{
				this.vramMirrorTable[i] = i;
			}

			this.lastRenderedScanline = -1;
			this.curX = 0;

			for (i = 0 ; i < this.oldFrame.length ; i++)
			{
				this.oldFrame[i] = -1;
			}
		}
		
		public	function setMirroring(mirroring:int):void
		{
			if (mirroring == this.currentMirroring)
				return;

			this.currentMirroring = mirroring;
			triggerRendering();

			if (this.vramMirrorTable == null)
			{
				this.vramMirrorTable = new Vector.<int>(0x8000);
			}
			for (var i:int = 0 ; i < 0x8000 ; i++)
			{
				this.vramMirrorTable[i] = i;
			}

			defineMirrorRegion(0x3f20,0x3f00,0x20);
			defineMirrorRegion(0x3f40,0x3f00,0x20);
			defineMirrorRegion(0x3f80,0x3f00,0x20);
			defineMirrorRegion(0x3fc0,0x3f00,0x20);

			defineMirrorRegion(0x3000,0x2000,0xf00);
			defineMirrorRegion(0x4000,0x0000,0x4000);

			if (mirroring == ROM.HORIZONTAL_MIRRORING)
			{
				this.ntable1[0] = 0;
				this.ntable1[1] = 0;
				this.ntable1[2] = 1;
				this.ntable1[3] = 1;

				defineMirrorRegion(0x2400,0x2000,0x400);
				defineMirrorRegion(0x2c00,0x2800,0x400);
			}
			else if (mirroring == ROM.VERTICAL_MIRRORING)
			{
				this.ntable1[0] = 0;
				this.ntable1[1] = 1;
				this.ntable1[2] = 0;
				this.ntable1[3] = 1;

				defineMirrorRegion(0x2800,0x2000,0x400);
				defineMirrorRegion(0x2c00,0x2400,0x400);
			}
			else if (mirroring == ROM.SINGLESCREEN_MIRRORING)
			{
				this.ntable1[0] = 0;
				this.ntable1[1] = 0;
				this.ntable1[2] = 0;
				this.ntable1[3] = 0;

				defineMirrorRegion(0x2400,0x2000,0x400);
				defineMirrorRegion(0x2800,0x2000,0x400);
				defineMirrorRegion(0x2c00,0x2000,0x400);
			}
			else if (mirroring == ROM.SINGLESCREEN_MIRRORING2)
			{
				this.ntable1[0] = 1;
				this.ntable1[1] = 1;
				this.ntable1[2] = 1;
				this.ntable1[3] = 1;

				defineMirrorRegion(0x2400,0x2400,0x400);
				defineMirrorRegion(0x2800,0x2400,0x400);
				defineMirrorRegion(0x2c00,0x2400,0x400);
			}
			else
			{
				this.ntable1[0] = 0;
				this.ntable1[1] = 1;
				this.ntable1[2] = 2;
				this.ntable1[3] = 3;
			}
		}
		
		private	function defineMirrorRegion(fromStart:int, toStart:int, size:int):void
		{
			for(var i:int = 0 ; i < size ; i++)
			{
				this.vramMirrorTable[fromStart+i] = toStart + i;
			}
		}

		public	function emulateCycles():void
		{
			for ( ; cycles > 0 ; cycles--)
			{
				if (this.scanline-21 == this.spr0HitY)
				{
					if ((curX == spr0HitX) && (f_spVisibility==1))
					{
						setStatusFlag(STATUS_SPRITE0HIT, true);
					}
				}
	
				if (this.requestEndFrame)
				{
					this.nmiCounter--;
					if (this.nmiCounter == 0)
					{
						this.requestEndFrame = false;
						startVBlank();
					}
				}

				this.curX++;
				if (this.curX == 341)
				{
					this.curX = 0;
					endScanline();
				}
			}
		}
	
		public	function startVBlank():void
		{
			if (Globals.debug)
			{
				Globals.println("VBlank occurs!");
			}

			this.nes.getCpu().requestIrq(CPU.IRQ_NMI);

			if (this.lastRenderedScanline < 239)
			{
				renderFramePartially(this.nes.getGui().getScreenView().getBuffer(), this.lastRenderedScanline+1, 240-this.lastRenderedScanline);
			}

			endFrame();

			this.nes.getGui().getScreenView().imageReady(false);
			this.lastRenderedScanline = -1;

			startFrame();
		}

		public	function endScanline():void
		{
			if (this.scanline < 19+this.vblankAdd)
			{
			}
			else if (this.scanline == 19+this.vblankAdd)
			{
				if (this.dummyCycleToggle)
				{
					this.curX = 1;
					this.dummyCycleToggle = !this.dummyCycleToggle;
				}
			}
			else if (this.scanline == 20+this.vblankAdd)
			{
				setStatusFlag(this.STATUS_VBLANK, false);

				setStatusFlag(this.STATUS_SPRITE0HIT, false);
				this.hitSpr0	= false;
				this.spr0HitX	= -1;
				this.spr0HitY	= -1;

				if ((this.f_bgVisibility == 1) || (this.f_spVisibility == 1))
				{
					this.cntFV	= this.regFV;
					this.cntV	= this.regV;
					this.cntH	= this.regH;
					this.cntVT	= this.regVT;
					this.cntHT	= this.regHT;

					if (this.f_bgVisibility == 1)
					{
						renderBgScanline(this.buffer, 0);
					}
				}
	
				if ((this.f_bgVisibility == 1) && (this.f_spVisibility == 1))
				{
					checkSprite0(0);
				}

				if ((f_bgVisibility == 1) || (f_spVisibility == 1))
				{
					nes.memMapper.clockIrqCounter();
				}
			}
			else if ((scanline >= (21+vblankAdd)) && (scanline <= 260))
			{
				if (this.f_bgVisibility == 1)
				{
					if (!this.scanlineAlreadyRendered)
					{
						this.cntHT = this.regHT;
						this.cntH = this.regH;
						renderBgScanline(this.bgbuffer, this.scanline+1-21);
					}
					this.scanlineAlreadyRendered=false;

					if ((!this.hitSpr0) && (this.f_spVisibility == 1))
					{
						if ((this.sprX[0]>=-7) && (this.sprX[0]<256) && (this.sprY[0]+1<=(this.scanline-this.vblankAdd+1-21)) && ((this.sprY[0]+1+(this.f_spriteSize==0 ? 8:16)) >= (this.scanline-this.vblankAdd+1-21)))
						{
							if (checkSprite0(this.scanline + this.vblankAdd + 1 - 21))
							{
								this.hitSpr0 = true;
							}
						}
					}
	
				}
	
				if ((this.f_bgVisibility==1) || (this.f_spVisibility==1))
				{
					this.nes.getMemoryMapper().clockIrqCounter();
				}
			}
			else if (this.scanline == (261 + this.vblankAdd))
			{
				setStatusFlag(this.STATUS_VBLANK, true);
				this.requestEndFrame = true;
				this.nmiCounter = 9;

				this.scanline = -1;
			}
	
			this.scanline++;
			regsToAddress();
			cntsToAddress();
		}
	
		public	function startFrame():void
		{
			var buffer:Vector.<int> = this.nes.getGui().getScreenView().getBuffer();

			var bgColor:int = 0;

			if (this.f_dispType == 0)
			{
				bgColor = this.imgPalette[0];
			}
			else
			{
				switch (this.f_color)
				{
				case 0:
					bgColor = 0x00000;
					break;
				case 1:
					bgColor = 0x00FF00;
					break;
				case 2:
					bgColor = 0xFF0000;
					break;
				case 3:
					bgColor = 0x000000;
					break;
				case 4:
					bgColor = 0x0000FF;
					break;
				default:
					bgColor = 0x0;
					break;
				}
			}
	
			var i:int;
			for (i = 0 ; i < this.buffer.length ; i++)
				this.buffer[i] = bgColor;
			for (i = 0 ; i < this.pixrendered.length ; i++)
				this.pixrendered[i] = 65;
		}
	
		public	function endFrame():void
		{
			var buffer:Vector.<int> = this.nes.getGui().getScreenView().getBuffer();
			var i:int, x:int, y:int;

			if (this.showSpr0Hit)
			{
				if ((this.sprX[0]>=0) && (this.sprX[0]<256) && (this.sprY[0]>=0) && (this.sprY[0]<240))
				{
					for (i = 0 ; i < 256 ; i++)
					{
						this.buffer[(this.sprY[0]<<8)+i] = 0xFF5555;
					}
					for (i = 0 ; i < 240 ; i++)
					{
						this.buffer[(i<<8)+this.sprX[0]] = 0xFF5555;
					}
				}

				if ((this.spr0HitX>=0) && (this.spr0HitX<256) && (this.spr0HitY>=0) && (this.spr0HitY<240))
				{
					for(i = 0 ; i < 256 ; i++)
					{
						this.buffer[(this.spr0HitY<<8)+i] = 0x55FF55;
					}
					for(i = 0 ; i < 240 ; i++)
					{
						this.buffer[(i<<8)+this.spr0HitX] = 0x55FF55;
					}
				}
			}
	
			if (this.clipToTvSize || (this.f_bgClipping==0) || (this.f_spClipping==0))
			{
				for (y = 0 ; y < 240 ; y++)
				{
					for (x = 0 ; x < 8 ; x++)
					{
						this.buffer[(y<<8)+x] = 0;
					}
				}
			}
	
			if (this.clipToTvSize)
			{
				for (y = 0 ; y < 240 ; y++)
				{
					for (x = 0 ; x < 8 ; x++)
					{
						this.buffer[(y<<8)+255-x] = 0;
					}
				}
			}

			if (this.clipToTvSize)
			{
				for (y = 0 ; y < 8 ; y++)
				{
					for (x = 0 ; x < 256 ; x++)
					{
						this.buffer[(y<<8)+x] = 0;
						this.buffer[((239-y)<<8)+x] = 0;
					}
				}
			}

			if (this.showSoundBuffer && (this.nes.getPapu().getLine() != null))
			{
				this.bufferSize	= this.nes.getPapu().getLine().getBufferSize();
				this.available	= this.nes.getPapu().getLine().available();
				this.scale		= this.bufferSize / 256;
	
				for (y = 0 ; y < 4 ; y++)
				{
					this.scanlineChanged[y] = true;
					for (x = 0 ; x < 256 ; x++)
					{
						if (x >= (this.available/this.scale))
						{
							this.buffer[y*256+x] = 0xFFFFFF;
						}
						else
						{
							this.buffer[y*256+x] = 0;
						}
					}
				}
			}
		}

		public	function updateControlReg1(value:int):void
		{
			triggerRendering();
	
			this.f_nmiOnVblank		= (value>>7)&1;
			this.f_spriteSize		= (value>>5)&1;
			this.f_bgPatternTable	= (value>>4)&1;
			this.f_spPatternTable	= (value>>3)&1;
			this.f_addrInc			= (value>>2)&1;
			this.f_nTblAddress		= value&3;

			this.regV = (value>>1)&1;
			this.regH = value&1;
			this.regS = (value>>4)&1;
		}

		public	function updateControlReg2(value:int):void
		{
			triggerRendering();
	
			this.f_color		= (value>>5)&7;
			this.f_spVisibility	= (value>>4)&1;
			this.f_bgVisibility	= (value>>3)&1;
			this.f_spClipping	= (value>>2)&1;
			this.f_bgClipping	= (value>>1)&1;
			this.f_dispType		= value&1;

			if (this.f_dispType == 0)
			{
				this.nes.palTable.setEmphasis(f_color);
			}
			updatePalettes();
	
		}
	
		public	function setStatusFlag(flag:int, value:Boolean):void
		{
			var n:int = 1 << flag;
			var memValue:int = this.nes.getCpuMemory().load(0x2002);
			memValue = ((memValue&(255-n))|(value?n:0));
			this.nes.getCpuMemory().write(0x2002, memValue);
		}

		public	function readStatusRegister():int
		{
			this.tmp = this.nes.getCpuMemory().load(0x2002);

			this.firstWrite = true;

			setStatusFlag(this.STATUS_VBLANK,false);

			return this.tmp;
		}

		public	function writeSRAMAddress(address:int):void
		{
			this.sramAddress = address;
		}

		public	function sramLoad():int
		{
			var tmp:int = this.sprMem.load(this.sramAddress);
			return tmp;
		}

		public	function sramWrite(value:int):void
		{
			this.sprMem.write(this.sramAddress,value);
			spriteRamWriteUpdate(this.sramAddress, value);
			this.sramAddress++;
			this.sramAddress %= 0x100;
		}

		public	function scrollWrite(value:int):void
		{
			triggerRendering();
			if (this.firstWrite)
			{
				this.regHT = (value>>3)&31;
				this.regFH = value&7;
			}
			else
			{
				this.regFV = value&7;
				this.regVT = (value>>3)&31;
			}
			this.firstWrite = !this.firstWrite;
		}

		public	function writeVRAMAddress(address:int):void
		{
			if (this.firstWrite)
			{
				this.regFV	= (address>>4)&3;
				this.regV	= (address>>3)&1;
				this.regH	= (address>>2)&1;
				this.regVT	= (this.regVT&7) | ((address&3)<<3);
			}
			else
			{
				triggerRendering();

				this.regVT = (this.regVT&24) | ((address>>5)&7);
				this.regHT = address&31;

				this.cntFV	= this.regFV;
				this.cntV	= this.regV;
				this.cntH	= this.regH;
				this.cntVT	= this.regVT;
				this.cntHT	= this.regHT;

				checkSprite0(this.scanline-this.vblankAdd+1-21);
			}
	
			this.firstWrite = !this.firstWrite;

			cntsToAddress();
			if (this.vramAddress < 0x2000)
			{
				this.nes.getMemoryMapper().latchAccess(this.vramAddress);
			}
		}

		public	function vramLoad():int
		{
			cntsToAddress();
			regsToAddress();

			var tmp:int;
			if (this.vramAddress <= 0x3EFF)
			{
				tmp = this.vramBufferedReadValue;

				if (this.vramAddress < 0x2000)
				{
					this.vramBufferedReadValue = this.ppuMem.load(this.vramAddress);
				}
				else
				{
					this.vramBufferedReadValue = mirroredLoad(this.vramAddress);
				}

				if (this.vramAddress < 0x2000)
				{
					this.nes.getMemoryMapper().latchAccess(this.vramAddress);
				}

				this.vramAddress += (this.f_addrInc==1 ? 32:1);

				cntsFromAddress();
				regsFromAddress();

				return tmp;
			}

			tmp = mirroredLoad(this.vramAddress);

			this.vramAddress += (this.f_addrInc==1 ? 32:1);

			cntsFromAddress();
			regsFromAddress();

			return tmp;
		}
		
		public	function vramWrite(value:int):void
		{
			triggerRendering();
			cntsToAddress();
			regsToAddress();
	
			if (this.vramAddress >= 0x2000)
			{
				mirroredWrite(this.vramAddress, value);
			}
			else
			{
				writeMem(this.vramAddress, value);
				this.nes.getMemoryMapper().latchAccess(this.vramAddress);
			}

			this.vramAddress += (this.f_addrInc==1 ? 32:1);
			regsFromAddress();
			cntsFromAddress();
		}

		public	function sramDMA(value:int):void
		{
			var cpuMem:Memory = this.nes.getCpuMemory();
			var baseAddress:int = value * 0x100;
			var data:int;
			for (var i:int = this.sramAddress ; i < 256 ; i++)
			{
				data = cpuMem.load(baseAddress + i);
				this.sprMem.write(i, data);
				spriteRamWriteUpdate(i, data);
			}
			this.nes.getCpu().haltCycles(513);
		}

		private	function regsFromAddress():void
		{
			this.address= (this.vramTmpAddress>>8)&0xFF;
			this.regFV	= (address>>4)&7;
			this.regV	= (address>>3)&1;
			this.regH	= (address>>2)&1;
			this.regVT	= (this.regVT&7) | ((address&3)<<3);
	
			this.address= this.vramTmpAddress&0xFF;
			this.regVT	= (this.regVT&24) | ((this.address>>5)&7);
			this.regHT	= this.address&31;
		}

		private	function cntsFromAddress():void
		{
			this.address= (this.vramAddress>>8)&0xFF;
			this.cntFV	= (this.address>>4)&3;
			this.cntV	= (this.address>>3)&1;
			this.cntH	= (this.address>>2)&1;
			this.cntVT	= (this.cntVT&7) | ((this.address&3)<<3);

			this.address= this.vramAddress&0xFF;
			this.cntVT	= (this.cntVT&24) | ((this.address>>5)&7);
			this.cntHT	= this.address&31;
		}

		private	function regsToAddress():void
		{
			this.b1  = (this.regFV&7) << 4;
			this.b1 |= (this.regV&1) << 3;
			this.b1 |= (this.regH&1) << 2;
			this.b1 |= (this.regVT>>3) & 3;

			this.b2  = (this.regVT&7) << 5;
			this.b2 |= this.regHT & 31;

			this.vramTmpAddress = ((this.b1<<8) | this.b2) & 0x7FFF;
		}
	
		private	function cntsToAddress():void
		{
			this.b1  = (this.cntFV&7) << 4;
			this.b1 |= (this.cntV&1) << 3;
			this.b1 |= (this.cntH&1) << 2;
			this.b1 |= (this.cntVT>>3) & 3;

			this.b2  = (this.cntVT&7) << 5;
			this.b2 |= this.cntHT & 31;

			this.vramAddress = ((this.b1<<8) | this.b2) & 0x7FFF;
		}

		private	function incTileCounter(count:int):void
		{
			for (i = count ; i != 0 ; i--)
			{
				this.cntHT++;
				if (this.cntHT == 32)
				{
					this.cntHT = 0;
					this.cntVT++;
					if (this.cntVT >= 30)
					{
						this.cntH++;
						if (this.cntH == 2)
						{
							this.cntH = 0;
							this.cntV++;
							if (this.cntV == 2)
							{
								this.cntV = 0;
								this.cntFV++;
								this.cntFV &= 0x7;
							}
						}
					}
				}
			}
		}

		private	function mirroredLoad(address:int):int
		{
			return this.ppuMem.load(this.vramMirrorTable[address]);
		}

		private	function mirroredWrite(address:int, value:int):void
		{
			if ((address>=0x3f00) && (address<0x3f20))
			{
				if (address==0x3F00 || address==0x3F10)
				{
					writeMem(0x3F00, value);
					writeMem(0x3F10, value);
				}
				else if (address==0x3F04 || address==0x3F14)
				{
					writeMem(0x3F04, value);
					writeMem(0x3F14, value);
				}
				else if (address==0x3F08 || address==0x3F18)
				{
					writeMem(0x3F08, value);
					writeMem(0x3F18, value);
				}
				else if (address==0x3F0C || address==0x3F1C)
				{
					writeMem(0x3F0C, value);
					writeMem(0x3F1C, value);
				}
				else
				{
					writeMem(address, value);
				}
			}
			else
			{
				if (address < this.vramMirrorTable.length)
				{
					writeMem(this.vramMirrorTable[address], value);
				}
				else
				{
					if (Globals.debug)
					{
						this.nes.getCpu().setCrashed(true);
					}
				}
			}
		}

		public	function triggerRendering():void
		{
			if ((this.scanline-this.vblankAdd>=21) && (this.scanline-this.vblankAdd<=260))
			{
				renderFramePartially(this.buffer, this.lastRenderedScanline+1, this.scanline-this.vblankAdd-21-this.lastRenderedScanline);
				this.lastRenderedScanline = this.scanline-this.vblankAdd-21;
			}
		}

		private	function renderFramePartially(buffer:Vector.<int>, startScan:int, scanCount:int):void
		{
			if ((this.f_spVisibility == 1) && (!Globals.disableSprites))
			{
				renderSpritesPartially(startScan, scanCount, true);
			}

			if (this.f_bgVisibility == 1)
			{
				this.si = startScan << 8;
				this.ei = (startScan+scanCount) << 8;
				if (ei > 0xF000)
					ei = 0xF000;
				for (this.destIndex = si ; this.destIndex < this.ei ; this.destIndex++)
				{
					if (this.pixrendered[this.destIndex] > 0xFF)
					{
						buffer[this.destIndex] = this.bgbuffer[this.destIndex];
					}
				}
			}

			if ((this.f_spVisibility == 1) && (!Globals.disableSprites))
			{
				renderSpritesPartially(startScan, scanCount, false);
			}

			var screen:BufferView = this.nes.getGui().getScreenView();
			if (screen.scalingEnabled() && (!screen.useHWScaling()) && (!this.requestRenderAll))
			{
				var i:int, j:int, jmax:int;
				if (startScan+scanCount > 240)
					scanCount = 240 - startScan;
				for (i = startScan ; i <  startScan+scanCount ; i++)
				{
					this.scanlineChanged[i] = false;
					this.si = i<<8;
					jmax = this.si+256;
					for (j = this.si ; j < jmax ; j++)
					{
						if (buffer[j] != this.oldFrame[j])
						{
							this.scanlineChanged[i] = true;
							break;
						}
						this.oldFrame[j] = buffer[j];
					}
					
					for (i = 0 ; i < jmax-j ; i++)
					{
						this.oldFrame[j+i] = buffer[j+i];
					}
				}
			}
			this.validTileData = false;
		}
	
		private	function renderBgScanline(buffer:Vector.<int>, scan:int):void
		{
			this.baseTile	= (this.regS==0?0:256);
			this.destIndex	= (scan<<8)-this.regFH;
			this.curNt		= this.ntable1[this.cntV+this.cntV+this.cntH];
	
			this.cntHT	= this.regHT;
			this.cntH	= this.regH;
			this.curNt	= this.ntable1[this.cntV+this.cntV+this.cntH];
	
			if(scan<240 && (scan-this.cntFV)>=0)
			{
				this.tscanoffset = this.cntFV<<3;
				y = scan-this.cntFV;
				for(this.tile = 0 ; this.tile < 32 ; this.tile++)
				{
					if (scan >= 0)
					{
						if (this.validTileData)
						{
							this.t = this.scantile[this.tile];
							this.tpix = this.t.pix;
							this.att = this.attrib[this.tile];
						}
						else
						{
							this.t = this.ptTile[this.baseTile+this.nameTable[this.curNt].getTileIndex(this.cntHT,this.cntVT)];
							this.tpix = this.t.pix;
							this.att = this.nameTable[this.curNt].getAttrib(this.cntHT,this.cntVT);
							this.scantile[this.tile] = this.t;
							this.attrib[this.tile] = this.att;
						}

						this.sx = 0;
						this.x = (this.tile<<3)-this.regFH;
						if (this.x > -8)
						{
							if (this.x < 0)
							{
								this.destIndex -= this.x;
								this.sx = -this.x;
							}
							if (this.t.opaque[this.cntFV])
							{
								for ( ; this.sx < 8 ; this.sx++)
								{
									buffer[this.destIndex] = this.imgPalette[this.tpix[this.tscanoffset+this.sx]+this.att];
									this.pixrendered[this.destIndex] |= 256;
									this.destIndex++;
								}
							}
							else
							{
								for ( ; this.sx < 8 ; this.sx++)
								{
									this.col = this.tpix[this.tscanoffset + this.sx];
									if (this.col != 0)
									{
										buffer[this.destIndex] = this.imgPalette[this.col+this.att];
										this.pixrendered[this.destIndex] |= 256;
									}
									this.destIndex++;
								}
							}
						}
	
					}
	
					cntHT++;
					if (cntHT == 32)
					{
						cntHT=0;
						cntH++;
						cntH%=2;
						curNt = ntable1[(cntV<<1)+cntH];
					}
				}
				validTileData = true;
			}

			cntFV++;
			if (cntFV == 8)
			{
				cntFV = 0;
				cntVT++;
				if (cntVT == 30)
				{
					cntVT = 0;
					cntV++;
					cntV%=2;
					curNt = ntable1[(cntV<<1)+cntH];
				}
				else if (cntVT == 32)
				{
					cntVT = 0;
				}

				validTileData = false;
			}
		}
	
		private	function renderSpritesPartially(startscan:int, scancount:int, bgPri:Boolean):void
		{
			buffer = nes.getGui().getScreenView().getBuffer();
			if (f_spVisibility == 1)
			{
				var sprT1:int, sprT2:int;
	
				for (var i:int = 0 ; i < 64 ; i++)
				{
					if ((bgPriority[i]==bgPri) && (sprX[i]>=0) && (sprX[i]<256) && (sprY[i]+8>=startscan) && (sprY[i]<startscan+scancount))
					{
						if (f_spriteSize == 0)
						{
							srcy1 = 0;
							srcy2 = 8;
	
							if (sprY[i] < startscan)
							{
								srcy1 = startscan - sprY[i]-1;
							}
	
							if (sprY[i]+8 > startscan+scancount)
							{
								srcy2 = startscan+scancount-sprY[i]+1;
							}
	
							if (f_spPatternTable == 0)
							{
								ptTile[sprTile[i]].render(0,srcy1,8,srcy2,sprX[i],sprY[i]+1,buffer,sprCol[i],sprPalette,horiFlip[i],vertFlip[i],i,pixrendered);
							}
							else
							{
								ptTile[sprTile[i]+256].render(0,srcy1,8,srcy2,sprX[i],sprY[i]+1,buffer,sprCol[i],sprPalette,horiFlip[i],vertFlip[i],i,pixrendered);
							}
						}
						else
						{
							var top:int = sprTile[i];
							if ((top&1) != 0)
							{
								top = sprTile[i]-1+256;
							}
	
							srcy1 = 0;
							srcy2 = 8;
	
							if (sprY[i] < startscan)
							{
								srcy1 = startscan - sprY[i]-1;
							}
	
							if (sprY[i]+8 > startscan+scancount)
							{
								srcy2 = startscan+scancount-sprY[i];
							}

							ptTile[top+(vertFlip[i]?1:0)].render(0,srcy1,8,srcy2,sprX[i],sprY[i]+1,buffer,sprCol[i],sprPalette,horiFlip[i],vertFlip[i],i,pixrendered);

							srcy1 = 0;
							srcy2 = 8;

							if (sprY[i]+8 < startscan)
							{
								srcy1 = startscan - (sprY[i]+8+1);
							}
	
							if (sprY[i]+16 > startscan+scancount)
							{
								srcy2 = startscan+scancount-(sprY[i]+8);
							}
	
							ptTile[top+(vertFlip[i]?0:1)].render(0,srcy1,8,srcy2,sprX[i],sprY[i]+1+8,buffer,sprCol[i],sprPalette,horiFlip[i],vertFlip[i],i,pixrendered);
						}
					}
				}
			}
		}
	
		private	function checkSprite0(scan:int):Boolean
		{
			spr0HitX = -1;
			spr0HitY = -1;
	
			var toffset:int;
			var tIndexAdd:int = (f_spPatternTable==0 ? 0:256);
			var x:int, y:int;
			var bufferIndex:int;
			var col:int;
			var bgPri:Boolean;
			var t:Tile;
			var i:int;
	
			x = sprX[0];
			y = sprY[0] + 1;
	
			if (f_spriteSize == 0)
			{
				if (y<=scan && y+8>scan && x>=-7 && x<256)
				{
					t = ptTile[sprTile[0]+tIndexAdd];
					col = sprCol[0];
					bgPri = bgPriority[0];
	
					if (vertFlip[0])
					{
						toffset = 7-(scan-y);
					}
					else
					{
						toffset = scan-y;
					}
					toffset *= 8;
	
					bufferIndex = scan * 256 + x;
					if (horiFlip[0])
					{
						for (i = 7 ; i >=0 ; i--)
						{
							if (x>=0 && x<256)
							{
								if (bufferIndex>=0 && bufferIndex<61440 && pixrendered[bufferIndex]!=0)
								{
									if (t.pix[toffset+i] != 0)
									{
										spr0HitX = bufferIndex%256;
										spr0HitY = scan;
										return true;
									}
								}
							}
							x++;
							bufferIndex++;
						}
					}
					else
					{
						for (i= 0 ; i < 8 ; i++)
						{
							if (x>=0 && x<256)
							{
								if (bufferIndex>=0 && bufferIndex<61440 && pixrendered[bufferIndex]!=0)
								{
									if (t.pix[toffset+i] != 0)
									{
										spr0HitX = bufferIndex%256;
										spr0HitY = scan;
										return true;
									}
								}
							}
							x++;
							bufferIndex++;
						}
					}
				}
			}
			else
			{
				if (y<=scan && y+16>scan && x>=-7 && x<256)
				{
					if (vertFlip[0])
					{
						toffset = 15-(scan-y);
					}
					else
					{
						toffset = scan-y;
					}
	
					if (toffset<8)
					{
						t = ptTile[sprTile[0]+(vertFlip[0]?1:0)+((sprTile[0]&1)!=0?255:0)];
					}
					else
					{
						t = ptTile[sprTile[0]+(vertFlip[0]?0:1)+((sprTile[0]&1)!=0?255:0)];
						if (vertFlip[0])
						{
							toffset = 15-toffset;
						}
						else
						{
							toffset -= 8;
						}
					}
					toffset*=8;
					col = sprCol[0];
					bgPri = bgPriority[0];
	
					bufferIndex = scan*256+x;
					if (horiFlip[0])
					{
						for (i = 7 ; i >= 0 ; i--)
						{
							if (x>=0 && x<256)
							{
								if (bufferIndex>=0 && bufferIndex<61440 && pixrendered[bufferIndex]!=0)
								{
									if (t.pix[toffset+i] != 0)
									{
										spr0HitX = bufferIndex%256;
										spr0HitY = scan;
										return true;
									}
								}
							}
							x++;
							bufferIndex++;
						}
					}
					else
					{
						for (i = 0 ; i < 8 ; i++)
						{
							if (x>=0 && x<256)
							{
								if (bufferIndex>=0 && bufferIndex<61440 && pixrendered[bufferIndex]!=0)
								{
									if (t.pix[toffset+i] != 0)
									{
										spr0HitX = bufferIndex%256;
										spr0HitY = scan;
										return true;
									}
								}
							}
							x++;
							bufferIndex++;
						}
					}
				}
			}
			return false;
		}
	
		public	function renderPattern():void
		{
			var scr:BufferView = nes.getGui().getPatternView();
			var buffer:Vector.<int> = scr.getBuffer();
	
			var tIndex:int = 0;
			for (var j:int = 0 ; j < 2 ; j++)
			{
				for (var y:int = 0 ; y < 16 ; y++)
				{
					for (var x:int = 0 ; x < 16 ; x++)
					{
						ptTile[tIndex].renderSimple(j*128+x*8,y*8,buffer,0,sprPalette);
						tIndex++;
					}
				}
			}
			nes.getGui().getPatternView().imageReady(false);
		}

		public	function renderNameTables():void
		{
			var buffer:Vector.<int> = nes.getGui().getNameTableView().getBuffer();
			if (f_bgPatternTable == 0)
			{
				baseTile = 0;
			}
			else
			{
				baseTile = 256;
			}
	
			var ntx_max:int = 2;
			var nty_max:int = 2;
	
			if (currentMirroring == ROM.HORIZONTAL_MIRRORING)
			{
				ntx_max = 1;
			}
			else if (currentMirroring == ROM.VERTICAL_MIRRORING)
			{
				nty_max = 1;
			}
	
			for (var nty:int = 0 ; nty < nty_max ; nty++)
			{
				for (var ntx:int = 0 ; ntx < ntx_max ; ntx++)
				{
					var nt:int = ntable1[nty*2+ntx];
					var x:int = ntx*128;
					var y:int = nty*120;
	
					for (var ty:int = 0 ; ty < 30 ; ty++)
					{
						for (var tx:int = 0 ; tx < 32 ; tx++)
						{
							ptTile[baseTile+nameTable[nt].getTileIndex(tx,ty)].renderSmall(x+tx*4,y+ty*4,buffer,nameTable[nt].getAttrib(tx,ty),imgPalette);
						}
					}
				}
			}
	
			if (currentMirroring == ROM.HORIZONTAL_MIRRORING)
			{
				for (y = 0 ; y < 240 ; y++)
				{
					for(x = 0 ; x < 128 ; x++)
					{
						buffer[(y<<8)+128+x] = buffer[(y<<8)+x];
					}
				}
			}
			else if (currentMirroring == ROM.VERTICAL_MIRRORING)
			{
				for (y = 0 ; y < 120 ; y++)
				{
					for (x = 0 ; x < 256 ; x++)
					{
						buffer[(y<<8)+0x7800+x] = buffer[(y<<8)+x];
					}
				}
			}
			nes.getGui().getNameTableView().imageReady(false);
		}
	
		private	function renderPalettes():void
		{
			var i:int, x:int, y:int;
			var buffer:Vector.<int> = nes.getGui().getImgPalView().getBuffer();
			for (i = 0 ; i < 16 ; i++)
			{
				for (y = 0 ; y < 16 ; y++)
				{
					for(x = 0 ; x < 16 ; x++)
					{
						buffer[y*256+i*16+x] = imgPalette[i];
					}
				}
			}
	
			buffer = nes.getGui().getSprPalView().getBuffer();
			for (i = 0 ; i < 16 ; i++)
			{
				for (y = 0 ; y < 16 ; y++)
				{
					for (x = 0 ; x < 16 ; x++)
					{
						buffer[y*256+i*16+x] = sprPalette[i];
					}
				}
			}
			nes.getGui().getImgPalView().imageReady(false);
			nes.getGui().getSprPalView().imageReady(false);
		}
	
		private	function writeMem(address:int, value:int):void
		{
			ppuMem.write(address, value);

			if (address < 0x2000)
			{
				ppuMem.write(address,value);
				patternWrite(address,value);
			}
			else if (address >=0x2000 && address <0x23c0)
			{
				nameTableWrite(ntable1[0],address-0x2000,value);
			}
			else if (address >=0x23c0 && address <0x2400)
			{
				attribTableWrite(ntable1[0],address-0x23c0,value);
			}
			else if (address >=0x2400 && address <0x27c0)
			{
				nameTableWrite(ntable1[1],address-0x2400,value);
			}
			else if (address >=0x27c0 && address <0x2800)
			{
				attribTableWrite(ntable1[1],address-0x27c0,value);
			}
			else if (address >=0x2800 && address <0x2bc0)
			{
				nameTableWrite(ntable1[2],address-0x2800,value);
			}
			else if (address >=0x2bc0 && address <0x2c00)
			{
				attribTableWrite(ntable1[2],address-0x2bc0,value);
			}
			else if (address >=0x2c00 && address <0x2fc0)
			{
				nameTableWrite(ntable1[3],address-0x2c00,value);
			}
			else if (address >=0x2fc0 && address <0x3000)
			{
				attribTableWrite(ntable1[3],address-0x2fc0,value);
			}
			else if (address >=0x3f00 && address <0x3f20)
			{
				updatePalettes();
			}
		}

		public	function updatePalettes():void
		{
			var i:int;
			for (i = 0 ; i < 16 ; i++)
			{
				if (f_dispType == 0)
				{
					imgPalette[i] = nes.palTable.getEntry(ppuMem.load(0x3f00+i)&63);
				}
				else
				{
					imgPalette[i] = nes.palTable.getEntry(ppuMem.load(0x3f00+i)&32);
				}
			}
			for (i = 0 ; i < 16 ; i++)
			{
				if (f_dispType == 0)
				{
					sprPalette[i] = nes.palTable.getEntry(ppuMem.load(0x3f10+i)&63);
				}
				else
				{
					sprPalette[i] = nes.palTable.getEntry(ppuMem.load(0x3f10+i)&32);
				}
			}
		}

		public	function patternWrite(address:int, value:int):void
		{
			var tileIndex:int = address/16;
			var leftOver:int = address%16;
			if (leftOver<8)
			{
				ptTile[tileIndex].setScanline(leftOver,value,ppuMem.load(address+8));
			}
			else
			{
				ptTile[tileIndex].setScanline(leftOver-8,ppuMem.load(address-8),value);
			}
		}

		public	function patternWriteAt(address:int, value:Vector.<int>, offset:int, length:int):void
		{
			var tileIndex:int;
			var leftOver:int;
	
			for (var i:int = 0 ; i < length ; i++)
			{
				tileIndex = (address+i)>>4;
				leftOver = (address+i) % 16;
	
				if (leftOver < 8)
				{
					ptTile[tileIndex].setScanline(leftOver,value[offset+i],ppuMem.load(address+8+i));
				}
				else
				{
					ptTile[tileIndex].setScanline(leftOver-8,ppuMem.load(address-8+i),value[offset+i]);
				}
			}
		}
	
		public	function invalidateFrameCache():void
		{
			var i:int;
			for (i = 0 ; i < 240 ; i++)
			{
				scanlineChanged[i]=true;
			}
			for (i = 0 ; i < oldFrame.length ; i++)
			{
				oldFrame[i] = -1;
			}
			requestRenderAll = true;
		}

		public	function nameTableWrite(index:int, address:int, value:int):void
		{
			nameTable[index].writeTileIndex(address,value);
			checkSprite0(scanline+1-vblankAdd-21);
		}

		public	function attribTableWrite(index:int, address:int, value:int):void
		{
			nameTable[index].writeAttrib(address,value);
		}

		public	function spriteRamWriteUpdate(address:int, value:int):void
		{
			var tIndex:int = address/4;
	
			if (tIndex == 0)
			{
				checkSprite0(scanline+1-vblankAdd-21);
			}
	
			if (address%4 == 0)
			{
				sprY[tIndex] = value;
			}
			else if (address%4 == 1)
			{
				sprTile[tIndex] = value;
			}
			else if (address%4 == 2)
			{
				vertFlip[tIndex] = ((value&0x80)!=0);
				horiFlip[tIndex] = ((value&0x40)!=0);
				bgPriority[tIndex] = ((value&0x20)!=0);
				sprCol[tIndex] = (value&3)<<2;
			}
			else if (address%4 == 3)
			{
				sprX[tIndex] = value;
			}
		}
	
		public	function doNMI():void
		{
			setStatusFlag(STATUS_VBLANK,true);
			nes.getCpu().requestIrq(CPU.IRQ_NMI);
		}
	
		public	function statusRegsToInt():int
		{
			var ret:int = 0;
			ret = 	(f_nmiOnVblank) |
					(f_spriteSize<<1) |
					(f_bgPatternTable<<2) |
					(f_spPatternTable<<3) |
					(f_addrInc<<4) |
					(f_nTblAddress<<5) |
					(f_color<<6) |
					(f_spVisibility<<7) |
					(f_bgVisibility<<8) |
					(f_spClipping<<9) |
					(f_bgClipping<<10) |
					(f_dispType<<11);
			return ret;
		}

		public	function statusRegsFromInt(n:int):void
		{
			f_nmiOnVblank     = (n    )&0x1;
			f_spriteSize      = (n>>1 )&0x1;
			f_bgPatternTable  = (n>>2 )&0x1;
			f_spPatternTable  = (n>>3 )&0x1;
			f_addrInc         = (n>>4 )&0x1;
			f_nTblAddress     = (n>>5 )&0x1;
	
			f_color           = (n>>6 )&0x1;
			f_spVisibility    = (n>>7 )&0x1;
			f_bgVisibility    = (n>>8 )&0x1;
			f_spClipping      = (n>>9 )&0x1;
			f_bgClipping      = (n>>10)&0x1;
			f_dispType        = (n>>11)&0x1;
		}
	
		public	function stateLoad(buf:ByteBuffer):void
		{
			var i:int;
			if (buf.readByte() == 1)
			{
				cntFV = buf.readInt();
				cntV = buf.readInt();
				cntH = buf.readInt();
				cntVT = buf.readInt();
				cntHT = buf.readInt();

				regFV = buf.readInt();
				regV = buf.readInt();
				regH = buf.readInt();
				regVT = buf.readInt();
				regHT = buf.readInt();
				regFH = buf.readInt();
				regS = buf.readInt();

				vramAddress = buf.readInt();
				vramTmpAddress = buf.readInt();

				statusRegsFromInt(buf.readInt());

				vramBufferedReadValue = buf.readInt();
				firstWrite = buf.readBoolean();

				for (i = 0 ; i < vramMirrorTable.length ; i++)
				{
					vramMirrorTable[i] = buf.readInt();
				}

				sramAddress = buf.readInt();

				curX = buf.readInt();
				scanline = buf.readInt();
				lastRenderedScanline = buf.readInt();

				requestEndFrame = buf.readBoolean();
				nmiOk = buf.readBoolean();
				dummyCycleToggle = buf.readBoolean();
				nmiCounter = buf.readInt();
				tmp = buf.readInt();

				for (i = 0 ; i < bgbuffer.length ; i++)
				{
					bgbuffer[i] = buf.readByte();
				}
				for (i = 0 ; i < pixrendered.length ; i++)
				{
					pixrendered[i] = buf.readByte();
				}

				for (i = 0 ; i < 4 ; i++)
				{
					ntable1[i] = buf.readByte();
					nameTable[i].stateLoad(buf);
				}

				for (i = 0 ; i < ptTile.length ; i++)
				{
					ptTile[i].stateLoad(buf);
				}

				var sprmem:Vector.<int> = nes.getSprMemory().mem;
				for (i = 0 ; i < sprmem.length ; i++)
				{
					spriteRamWriteUpdate(i,sprmem[i]);
				}
			}
		}
	
		public	function stateSave(buf:ByteBuffer):void
		{
			var i:int;
			buf.putByte(1);
	
			buf.putInt(cntFV);
			buf.putInt(cntV);
			buf.putInt(cntH);
			buf.putInt(cntVT);
			buf.putInt(cntHT);

			buf.putInt(regFV);
			buf.putInt(regV);
			buf.putInt(regH);
			buf.putInt(regVT);
			buf.putInt(regHT);
			buf.putInt(regFH);
			buf.putInt(regS);
	
			buf.putInt(vramAddress);
			buf.putInt(vramTmpAddress);
	
			buf.putInt(statusRegsToInt());
	
			buf.putInt(vramBufferedReadValue);
			buf.putBoolean(firstWrite);
	
			for (i = 0 ; i < vramMirrorTable.length ; i++)
			{
				buf.putInt(vramMirrorTable[i]);
			}
	
			buf.putInt(sramAddress);
	
			buf.putInt(curX);
			buf.putInt(scanline);
			buf.putInt(lastRenderedScanline);
	
			buf.putBoolean(requestEndFrame);
			buf.putBoolean(nmiOk);
			buf.putBoolean(dummyCycleToggle);
			buf.putInt(nmiCounter);
			buf.putInt(tmp);
	
			for (i = 0 ; i < bgbuffer.length ; i++)
			{
				buf.putByte(bgbuffer[i]);
			}
			for (i = 0 ; i < pixrendered.length ; i++)
			{
				buf.putByte(pixrendered[i]);
			}
	
			for (i = 0 ; i < 4 ; i++)
			{
				buf.putByte(ntable1[i]);
				nameTable[i].stateSave(buf);
			}
	
			for (i = 0 ; i < ptTile.length ; i++)
			{
				ptTile[i].stateSave(buf);
			}
		}

		public	function reset():void
		{
	
			ppuMem.reset();
			sprMem.reset();
	
			vramBufferedReadValue = 0;
			sramAddress           = 0;
			curX                  = 0;
			scanline              = 0;
			lastRenderedScanline  = 0;
			spr0HitX              = 0;
			spr0HitY              = 0;
			mapperIrqCounter	  = 0;
	
			currentMirroring = -1;
	
			firstWrite = true;
			requestEndFrame = false;
			nmiOk = false;
			hitSpr0 = false;
			dummyCycleToggle = false;
			validTileData = false;
			nmiCounter = 0;
			tmp = 0;
			att = 0;
			i = 0;
	
			// Control Flags Register 1:
			f_nmiOnVblank = 0;    // NMI on VBlank. 0=disable, 1=enable
			f_spriteSize = 0;     // Sprite size. 0=8x8, 1=8x16
			f_bgPatternTable = 0; // Background Pattern Table address. 0=0x0000,1=0x1000
			f_spPatternTable = 0; // Sprite Pattern Table address. 0=0x0000,1=0x1000
			f_addrInc = 0;        // PPU Address Increment. 0=1,1=32
			f_nTblAddress = 0;    // Name Table Address. 0=0x2000,1=0x2400,2=0x2800,3=0x2C00
	
			// Control Flags Register 2:
			f_color = 0;	   	  // Background color. 0=black, 1=blue, 2=green, 4=red
			f_spVisibility = 0;   // Sprite visibility. 0=not displayed,1=displayed
			f_bgVisibility = 0;   // Background visibility. 0=Not Displayed,1=displayed
			f_spClipping = 0;     // Sprite clipping. 0=Sprites invisible in left 8-pixel column,1=No clipping
			f_bgClipping = 0;     // Background clipping. 0=BG invisible in left 8-pixel column, 1=No clipping
			f_dispType = 0;       // Display type. 0=color, 1=monochrome
	
	
			// Counters:
			cntFV = 0;
			cntV = 0;
			cntH = 0;
			cntVT = 0;
			cntHT = 0;
	
			// Registers:
			regFV = 0;
			regV = 0;
			regH = 0;
			regVT = 0;
			regHT = 0;
			regFH = 0;
			regS = 0;
	
			var i:int;
			for (i = 0 ; i < scanlineChanged.length ; i++)
			{
				scanlineChanged[i] = true;
			}
			for (i = 0 ; i < oldFrame.length ; i++)
			{
				oldFrame[i] = -1;
			}
	
			// Initialize stuff:
			init();
	
		}
	
		public	function destroy():void
		{
			nes = null;
			ppuMem = null;
			sprMem = null;
			scantile = null;
		}
	}
}