package com.mobswing.model
{
	import com.mobswing.control.GameGenie;
	import com.mobswing.control.IUI;
	
	public class Nes
	{
		public	var gui			:IUI;
		public	var cpu			:CPU;
		public	var ppu			:PPU;
		public	var papu		:PAPU;
		public	var cpuMem		:Memory;
		public	var ppuMem		:Memory;
		public	var sprMem		:Memory;
		public	var memMapper	:IMemoryMapper;
		public	var palTable	:PaletteTable;
		public	var rom			:ROM;
		public	var gameGenie	:GameGenie;
		
		public	var romFile		:String;
		private	var running		:Boolean = false;

		public function Nes(gui:IUI)
		{
			Globals.nes = this;
			this.gui = gui;
			
			//Create memory
			this.cpuMem = new Memory(this, 0x10000);	//Main Memory (internal to CPU)
			this.ppuMem = new Memory(this, 0x8000);		//VRAM memory (internal to PPU)
			this.sprMem = new Memory(this, 0x100);		//Sprite RAM (internal to PPU)
			
			//Create system units
			this.cpu		= new CPU(this);
			this.palTable	= new PaletteTable();
			this.ppu		= new PPU(this);
			this.papu		= new PAPU(this);
			this.gameGenie	= new GameGenie();
			
			//Init sound register
			for (var i:int = 0 ; i < 0x14 ; i++)
			{
				if (i == 0x10)
					this.papu.writeReg(0x4010, 0x10);
				else
					this.papu.writeReg(0x4000+i, 0);
			}
			
			//Load NTSC Palette
			if (!this.palTable.loadNTSCPalette())
			{
				this.palTable.loadDefaultPalette();
			}
			
			//initialize units
			this.cpu.init();
			this.ppu.init();
			
			//Enable Sound
			enableSound(true);
			
			//Clear CPU Memory
			clearCPUMemory();
		}

		public	function stateLoad(buf:ByteBuffer):Boolean
		{
			var continueEmulation:Boolean = false;
			var success:Boolean;
			
			//pause emulation
			if (this.cpu.isRunning())
			{
				continueEmulation = true;
				stopEmulation();
			}
			
			//check version
			if (buf.readByte() == 1)
			{
				this.cpuMem.stateLoad(buf);
				this.ppuMem.stateLoad(buf);
				this.sprMem.stateLoad(buf);
				this.cpu.stateLoad(buf);
				this.memMapper.stateLoad(buf);
				this.ppu.stateLoad(buf);
			}
			else
			{
				success = false;
			}
			
			//resume emulation
			if (continueEmulation)
			{
				startEmulation();
			}
			
			return success;
		}
		
		public	function stateSave(buf:ByteBuffer):void
		{
			var continueEmulation:Boolean = isRunning();
			stopEmulation();
			
			//version
			buf.putByte(1);
			
			//let units save their state
			this.cpuMem.stateSave(buf);
			this.ppuMem.stateSave(buf);
			this.sprMem.stateSave(buf);
			this.cpu.stateSave(buf);
			this.memMapper.stateSave(buf);
			this.ppu.stateSave(buf);
			
			//continue emulation
			if (continueEmulation)
			{
				startEmulation();
			}
		}
		
		public	function isRunning():Boolean
		{
			return this.running;
		}
		
		public	function startEmulation():void
		{
			if (Globals.enableSound && !this.papu.isRunning())
			{
				this.papu.start();
			}
			
			if (this.rom!=null && this.rom.isValid() && !this.cpu.isRunning())
			{
				this.cpu.beginExcution();
				this.running = true;
			}
		}
		
		public	function stopEmulation():void
		{
			if (this.cpu.isRunning())
			{
				this.cpu.endExcution();
				this.running = false;
			}
			
			if (Globals.enableSound && this.papu.isRunning())
			{
				this.papu.stop();
			}
		}
		
		public	function reloadRom():void
		{
			if (this.romFile != null)
			{
				loadRom(this.romFile);
			}
		}
		
		public	function clearCPUMemory():void
		{
			var flushval:int = Globals.memoryFlushValue;
			for (var i:int = 0 ; 0x2000 ; i++)
			{
				cpuMem.mem[i] = flushval;
			}
			for (var p:int = 0 ; p < 4 ; p++)
			{
				i = p * 0x800;
				cpuMem.mem[i+0x008] = 0xF7;
				cpuMem.mem[i+0x009] = 0xEF;
				cpuMem.mem[i+0x00A] = 0xDF;
				cpuMem.mem[i+0x00F] = 0xBF;
			}
		}
		
		public	function setGameGenieState(enable:Boolean):void
		{
			if (this.memMapper != null)
			{
				this.memMapper.setGameGenieState(enable);
			}
		}
		
		public	function getCpu():CPU
		{
			return this.cpu;
		}
		
		public	function getPpu():PPU
		{
			return this.ppu;
		}
		
		public	function getPapu():PAPU
		{
			return this.papu;
		}
		
		public	function getCpuMemory():Memory
		{
			return this.cpuMem;
		}
		
		public	function getPpuMemory():Memory
		{
			return this.ppuMem;
		}
		
		public	function getSprMemory():Memory
		{
			return this.sprMem;
		}
		
		public	function getRom():ROM
		{
			return rom;
		}

		public	function getGui():IUI
		{
			return this.gui; 
		}
		
		public	function getMemoryMapper():IMemoryMapper
		{
			return this.memMapper;
		}
		
		public	function getGameGenie():GameGenie
		{
			return this.gameGenie;
		}
		
		public	function loadRom(file:String):Boolean
		{
			return false;
		}
		
		public	function reset():void
		{
			;
		}
		
		public	function enableSound(enable:Boolean):void
		{
			;
		}
		
		public	function setFrameRate(rate:int):void
		{
			;
		}
		
		public	function destroy():void
		{
			;
		}
	}
}