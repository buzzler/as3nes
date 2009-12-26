package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	
	public class CPU
	{
		private	var myThread:PseudoThread;
	
		private	var nes	:Nes;
		private	var mmap:IMemoryMapper;
		private	var mem	:Vector.<int>;
	
		public	var REG_ACC_NEW		:int;
		public	var	REG_X_NEW		:int;
		public	var REG_Y_NEW		:int;
		public	var REG_STATUS_NEW	:int;
		public	var REG_PC_NEW		:int;
		public	var REG_SP			:int;
	
		private var F_CARRY_NEW		:int;
		private var F_ZERO_NEW		:int;
		private var F_INTERRUPT_NEW	:int;
		private var F_DECIMAL_NEW	:int;
		private var F_BRK_NEW		:int;
		private var F_NOTUSED_NEW	:int;
		private var F_OVERFLOW_NEW	:int;
		private var F_SIGN_NEW		:int;
		
		public static const IRQ_NORMAL:int = 0;
		public static const IRQ_NMI:int    = 1;
		public static const IRQ_RESET:int  = 2;
		
		public	var irqRequested	:Boolean;
		private	var irqType			:int;
	
		private	var opdata			:Vector.<int>;
	
		public	var cyclesToHalt	:int;
		public	var stopRunning		:Boolean;
		public	var crash			:Boolean;
		
//////////////////////////////////////////////
/////////////////for loop/////////////////////
//////////////////////////////////////////////		
		
		private	var ppu			:PPU;
		private	var papu		:PAPU;

		private	var REG_ACC		:int;
		private	var REG_X		:int;
		private	var REG_Y		:int;
		private	var REG_STATUS	:int;
		private	var REG_PC		:int;

		private	var F_CARRY		:int;
		private	var F_ZERO		:int;
		private	var F_INTERRUPT	:int;
		private	var F_DECIMAL	:int;
		private	var F_NOTUSED	:int;
		private	var F_BRK		:int;
		private	var F_OVERFLOW	:int;
		private	var F_SIGN		:int;

		private	var opinf		:int;
		private	var opaddr		:int;
		private	var addrMode	:int;
		private	var addr		:int;
		private	var	palCnt		:int;
		private	var cycleCount	:int;
		private	var cycleAdd	:int;
		private	var temp		:int;
		private	var add			:int;

		private	var palEmu		:Boolean;
		private	var	emulateSound:Boolean;
		private	var asApplet	:Boolean;
		
//////////////////////////////////////////////
/////////////////for loop/////////////////////
//////////////////////////////////////////////
		
		public function CPU(nes:Nes)
		{
			this.nes = nes;
		}
		
		public	function init():void
		{
			this.opdata = CpuInfo.getOpData();
	
			this.mmap = this.nes.getMemoryMapper();
	
			this.crash = false;
	
			this.F_BRK_NEW = 1;
			this.F_NOTUSED_NEW = 1;
			this.F_INTERRUPT_NEW = 1;
			this.irqRequested = false;
		}
		
		public	function stateLoad(buf:ByteBuffer):void
		{
			if(buf.readByte()==1)
			{
				setStatus(buf.readInt());
				this.REG_ACC_NEW= buf.readInt();
				this.REG_PC_NEW	= buf.readInt();
				this.REG_SP		= buf.readInt();
				this.REG_X_NEW	= buf.readInt();
				this.REG_Y_NEW	= buf.readInt();

				this.cyclesToHalt = buf.readInt();
			}
		}
	
		public	function stateSave(buf:ByteBuffer):void
		{
			// Save info version:
			buf.putByte(1);
	
			// Save registers:
			buf.putInt(getStatus());
			buf.putInt(this.REG_ACC_NEW);
			buf.putInt(this.REG_PC_NEW );
			buf.putInt(this.REG_SP     );
			buf.putInt(this.REG_X_NEW  );
			buf.putInt(this.REG_Y_NEW  );
	
			// Cycles to halt:
			buf.putInt(this.cyclesToHalt);
		}
	
		public	function reset():void
		{
			this.REG_ACC_NEW = 0;
			this.REG_X_NEW = 0;
			this.REG_Y_NEW = 0;
	
			this.irqRequested = false;
			this.irqType = 0;
	
			// Reset Stack pointer:
			this.REG_SP = 0x01FF;
	
			// Reset Program counter:
			this.REG_PC_NEW = 0x8000-1;
	
			// Reset Status register:
			this.REG_STATUS_NEW = 0x28;
			setStatus(0x28);
	
			// Reset crash flag:
			this.crash = false;
	
			// Set flags:
			this.F_CARRY_NEW = 0;
			this.F_DECIMAL_NEW = 0;
			this.F_INTERRUPT_NEW = 1;
			this.F_OVERFLOW_NEW = 0;
			this.F_SIGN_NEW = 0;
			this.F_ZERO_NEW = 0;
	
			this.F_NOTUSED_NEW = 1;
			this.F_BRK_NEW = 1;
	
			this.cyclesToHalt = 0;
		}
	
		public	function beginExcution():void
		{
			if (isRunning())
			{
				endExcution();
			}
	
			/* this.myThread = new Thread(this);
			this.myThread.start();
			this.myThread.setPriority(Thread.MIN_PRIORITY); */
			run();
		}
	
		public	function endExcution():void
		{
			if (isRunning())
			{
				this.stopRunning = true;
				/* this.myThread.join(); */
			}
		}
	
		public	function isRunning():Boolean
		{
			return (this.myThread!=null && this.myThread.isAlive());
		}
	
		public	function run():void
		{
			initRun();
			emulate();
		}
	
		public	function initRun():void
		{
			this.stopRunning = false;
		}
		
		public	function emulate():void
		{
			// NES Memory
			// (when memory mappers switch ROM banks
			// this will be written to, no need to
			// update reference):
			this.mem = this.nes.getCpuMemory().mem;
	
			// References to other parts of NES:
			this.ppu		= this.nes.getPpu();
			this.papu		= this.nes.getPapu();

			// Registers:
			this.REG_ACC	= this.REG_ACC_NEW;
			this.REG_X		= this.REG_X_NEW;
			this.REG_Y		= this.REG_Y_NEW;
			this.REG_STATUS	= this.REG_STATUS_NEW;
			this.REG_PC		= this.REG_PC_NEW;

			// Status flags:
			this.F_CARRY 	= this.F_CARRY_NEW;
			this.F_ZERO 	= (this.F_ZERO_NEW==0?1:0);
			this.F_INTERRUPT= this.F_INTERRUPT_NEW;
			this.F_DECIMAL 	= this.F_DECIMAL_NEW;
			this.F_NOTUSED	= this.F_NOTUSED_NEW;
			this.F_BRK		= this.F_BRK_NEW;
			this.F_OVERFLOW	= this.F_OVERFLOW_NEW;
			this.F_SIGN 	= this.F_SIGN_NEW;

			// Misc. variables
			this.opinf		= 0;
			this.opaddr		= 0;
			this.addrMode	= 0;
			this.addr		= 0;
			this.palCnt		= 0;

			this.palEmu			= Globals.palEmulation;
			this.emulateSound	= Globals.enableSound;
			this.asApplet		= Globals.movieclipMode;
			this.stopRunning	= false;
			
			this.myThread = new PseudoThread(this.nes.getGui().getStage(), this.loop, null);
			this.myThread.addEventListener(Event.COMPLETE, onLoopComplete);
		}
		
		private function loop(obj:Object):Boolean
		{
			if (stopRunning)
				return false;

			if (irqRequested)
			{

				temp = (F_CARRY)|((F_ZERO==0?1:0)<<1)|(F_INTERRUPT<<2)|(F_DECIMAL<<3)|(F_BRK<<4)|(F_NOTUSED<<5)|(F_OVERFLOW<<6)|(F_SIGN<<7);

				REG_PC_NEW = REG_PC;
				F_INTERRUPT_NEW = F_INTERRUPT;
				switch (irqType)
				{
				case 0:
					if (F_INTERRUPT != 0)
						break;
					doIrq(temp);
					break;
				case 1:
					doNonMaskableInterrupt(temp);
					break;
				case 2:
					doResetInterrupt();
					break;
				}
				REG_PC		= REG_PC_NEW;
				F_INTERRUPT	= F_INTERRUPT_NEW;
				F_BRK		= F_BRK_NEW;
				irqRequested= false;
			}

			opinf = opdata[mmap.load(REG_PC+1)];
			cycleCount = (opinf>>24);
			cycleAdd = 0;

			addrMode = (opinf>>8)&0xFF;

			opaddr = REG_PC;
			REG_PC += ((opinf>>16)&0xFF);

			switch (addrMode)
			{
			case 0:
				addr = load(opaddr+2);
				break;
			case 1:
				addr = load(opaddr+2);
				if (addr<0x80)
					addr += REG_PC;
				else
					addr += REG_PC-256;
				break;
			case 2:
				break;
			case 3:
				addr = load16bit(opaddr+2);
				break;
			case 4:
				addr = REG_ACC;
				break;
			case 5:
				addr = REG_PC;
				break;
			case 6:
				addr = (load(opaddr+2)+REG_X) & 0xFF;
				break;
			case 7:
				addr = (load(opaddr+2)+REG_Y) & 0xFF;
				break;
			case 8:
				addr = load16bit(opaddr+2);
				if ((addr&0xFF00) != ((addr+REG_X)&0xFF00))
					cycleAdd = 1;
				addr += REG_X;
				break;
			case 9:
				addr = load16bit(opaddr+2);
				if ((addr&0xFF00) != ((addr+REG_Y)&0xFF00))
					cycleAdd = 1;
				addr += REG_Y;
				break;
			case 10:
				addr = load(opaddr+2);
				if ((addr&0xFF00) != ((addr+REG_X)&0xFF00))
					cycleAdd = 1;
				addr += REG_X;
				addr &= 0xFF;
				addr = load16bit(addr);
				break;
			case 11:
				addr = load16bit(load(opaddr+2));
				if ((addr&0xFF00) != ((addr+REG_Y)&0xFF00))
					cycleAdd = 1;
				addr += REG_Y;
				break;
			case 12:
				addr = load16bit(opaddr+2);
				if (addr < 0x1FFF)
					addr = mem[addr] + (mem[(addr&0xFF00)|(((addr&0xFF)+1)&0xFF)]<<8);
				else
					addr = mmap.load(addr) + (mmap.load((addr&0xFF00)|(((addr&0xFF)+1)&0xFF))<<8);
				break;
			}

			addr &= 0xFFFF;

			// ----------------------------------------------------------------------------------------------------
			// Decode & execute instruction:
			// ----------------------------------------------------------------------------------------------------

			switch(opinf&0xFF)
			{
			case 0:
				temp = REG_ACC + load(addr) + F_CARRY;
				F_OVERFLOW = ((!(((REG_ACC ^ load(addr)) & 0x80)!=0) && (((REG_ACC ^ temp) & 0x80))!=0)?1:0);
				F_CARRY = (temp>255?1:0);
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp&0xFF;
				REG_ACC = (temp&255);
				cycleCount+=cycleAdd;
				break;
			case 1:
				REG_ACC = REG_ACC & load(addr);
				F_SIGN = (REG_ACC>>7)&1;
				F_ZERO = REG_ACC;
				if (addrMode!=11)
					cycleCount += cycleAdd;
				break;
			case 2:
				if (addrMode == 4)
				{
					F_CARRY = (REG_ACC>>7)&1;
					REG_ACC = (REG_ACC<<1)&255;
					F_SIGN = (REG_ACC>>7)&1;
					F_ZERO = REG_ACC;
				}
				else
				{
					temp = load(addr);
					F_CARRY = (temp>>7)&1;
					temp = (temp<<1)&255;
					F_SIGN = (temp>>7)&1;
					F_ZERO = temp;
					write(addr, temp);
				}
				break;
			case 3:
				if (F_CARRY == 0)
				{
					cycleCount += ((opaddr&0xFF00)!=(addr&0xFF00)?2:1);
					REG_PC = addr;
				}
				break;
			case 4:
				if (F_CARRY == 1)
				{
					cycleCount += ((opaddr&0xFF00)!=(addr&0xFF00)?2:1);
					REG_PC = addr;
				}
				break;
			case 5:
				if (F_ZERO == 0)
				{
					cycleCount += ((opaddr&0xFF00)!=(addr&0xFF00)?2:1);
					REG_PC = addr;
				}
				break;
			case 6:
				temp = load(addr);
				F_SIGN = (temp>>7)&1;
				F_OVERFLOW = (temp>>6)&1;
				temp &= REG_ACC;
				F_ZERO = temp;
				break;
			case 7:
				if (F_SIGN == 1)
				{
					cycleCount++;
					REG_PC = addr;
				}
				break;
			case 8:
				if (F_ZERO != 0)
				{
					cycleCount += ((opaddr&0xFF00)!=(addr&0xFF00)?2:1);
					REG_PC = addr;
				}
				break;
			case 9:
				if (F_SIGN == 0)
				{
					cycleCount += ((opaddr&0xFF00)!=(addr&0xFF00)?2:1);
					REG_PC = addr;
				}
				break;
			case 10:
				REG_PC+=2;
				push((REG_PC>>8)&255);
				push(REG_PC&255);
				F_BRK = 1;

				push(
					(F_CARRY)|
					((F_ZERO==0?1:0)<<1)|
					(F_INTERRUPT<<2)|
					(F_DECIMAL<<3)|
					(F_BRK<<4)|
					(F_NOTUSED<<5)|
					(F_OVERFLOW<<6)|
					(F_SIGN<<7)
				);

				F_INTERRUPT = 1;
	    		//REG_PC = load(0xFFFE) | (load(0xFFFF) << 8);
	    		REG_PC = load16bit(0xFFFE);
	    		REG_PC--;
	    		break;
			case 11:
				if (F_OVERFLOW == 0)
				{
					cycleCount += ((opaddr&0xFF00)!=(addr&0xFF00)?2:1);
					REG_PC = addr;
				}
				break;
			case 12:
				if (F_OVERFLOW == 1)
				{
					cycleCount += ((opaddr&0xFF00)!=(addr&0xFF00)?2:1);
					REG_PC = addr;
				}
				break;
			case 13:
				F_CARRY = 0;
				break;
			case 14:
				F_DECIMAL = 0;
				break;
			case 15:
				F_INTERRUPT = 0;
				break;
			case 16:
				F_OVERFLOW = 0;
				break;
			case 17:
				temp = REG_ACC - load(addr);
				F_CARRY = (temp>=0?1:0);
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp&0xFF;
				cycleCount+=cycleAdd;
				break;
			case 18:
				temp = REG_X - load(addr);
				F_CARRY = (temp>=0?1:0);
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp&0xFF;
				break;
			case 19:
				temp = REG_Y - load(addr);
				F_CARRY = (temp>=0?1:0);
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp&0xFF;
				break;
			case 20:
				temp = (load(addr)-1)&0xFF;
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp;
				write(addr, temp);
				break;
			case 21:
				REG_X = (REG_X-1)&0xFF;
				F_SIGN = (REG_X>>7)&1;
				F_ZERO = REG_X;
				break;
			case 22:
				REG_Y = (REG_Y-1)&0xFF;
				F_SIGN = (REG_Y>>7)&1;
				F_ZERO = REG_Y;
				break;
			case 23:
				REG_ACC = (load(addr)^REG_ACC)&0xFF;
				F_SIGN = (REG_ACC>>7)&1;
				F_ZERO = REG_ACC;
				cycleCount+=cycleAdd;
				break;
			case 24:
				temp = (load(addr)+1)&0xFF;
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp;
				write(addr, (temp&0xFF));
				break;
			case 25:
				REG_X = (REG_X+1)&0xFF;
				F_SIGN = (REG_X>>7)&1;
				F_ZERO = REG_X;
				break;
			case 26:
				REG_Y++;
				REG_Y &= 0xFF;
				F_SIGN = (REG_Y>>7)&1;
				F_ZERO = REG_Y;
				break;
			case 27:
				REG_PC = addr-1;
				break;
			case 28:
				push((REG_PC>>8)&255);
				push(REG_PC&255);
				REG_PC = addr-1;
				break;
			case 29:
				REG_ACC = load(addr);
				F_SIGN = (REG_ACC>>7)&1;
				F_ZERO = REG_ACC;
				cycleCount+=cycleAdd;
				break;
			case 30:
				REG_X = load(addr);
				F_SIGN = (REG_X>>7)&1;
				F_ZERO = REG_X;
				cycleCount+=cycleAdd;
				break;
			case 31:
				REG_Y = load(addr);
				F_SIGN = (REG_Y>>7)&1;
				F_ZERO = REG_Y;
				cycleCount+=cycleAdd;
				break;
			case 32:
				if (addrMode == 4)
				{
					temp = (REG_ACC & 0xFF);
					F_CARRY = temp&1;
					temp >>= 1;
					REG_ACC = temp;
				}
				else
				{
					temp = load(addr) & 0xFF;
					F_CARRY = temp&1;
					temp >>= 1;
					write(addr, temp);
				}
				F_SIGN = 0;
				F_ZERO = temp;
				break;
			case 33:
				break;
			case 34:
				temp = (load(addr)|REG_ACC)&255;
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp;
				REG_ACC = temp;
				if(addrMode!=11)cycleCount+=cycleAdd; // PostIdxInd = 11
				break;
			case 35:
				push(REG_ACC);
				break;
			case 36:
				F_BRK = 1;
				push(
					(F_CARRY)|
					((F_ZERO==0?1:0)<<1)|
					(F_INTERRUPT<<2)|
					(F_DECIMAL<<3)|
					(F_BRK<<4)|
					(F_NOTUSED<<5)|
					(F_OVERFLOW<<6)|
					(F_SIGN<<7)
				);
				break;
			case 37:
				REG_ACC = pull();
				F_SIGN = (REG_ACC>>7)&1;
				F_ZERO = REG_ACC;
				break;
			case 38:
				temp = pull();
				F_CARRY     = (temp   )&1;
				F_ZERO      = (((temp>>1)&1)==1)?0:1;
				F_INTERRUPT = (temp>>2)&1;
				F_DECIMAL   = (temp>>3)&1;
				F_BRK       = (temp>>4)&1;
				F_NOTUSED   = (temp>>5)&1;
				F_OVERFLOW  = (temp>>6)&1;
				F_SIGN      = (temp>>7)&1;

				F_NOTUSED = 1;
				break;
			case 39:
				if (addrMode == 4)
				{
					temp = REG_ACC;
					add = F_CARRY;
					F_CARRY = (temp>>7)&1;
					temp = ((temp<<1)&0xFF)+add;
					REG_ACC = temp;
				}
				else
				{
					temp = load(addr);
					add = F_CARRY;
					F_CARRY = (temp>>7)&1;
					temp = ((temp<<1)&0xFF)+add;	
					write(addr, temp);
				}
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp;
				break;
			case 40:
				if (addrMode == 4)
				{
					add = F_CARRY<<7;
					F_CARRY = REG_ACC&1;
					temp = (REG_ACC>>1)+add;	
					REG_ACC = temp;
				}
				else
				{
					temp = load(addr);
					add = F_CARRY<<7;
					F_CARRY = temp&1;
					temp = (temp>>1)+add;
					write(addr, temp);
				}
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp;
				break;
			case 41:
				temp = pull();
				F_CARRY     = (temp   )&1;
				F_ZERO      = ((temp>>1)&1)==0?1:0;
				F_INTERRUPT = (temp>>2)&1;
				F_DECIMAL   = (temp>>3)&1;
				F_BRK       = (temp>>4)&1;
				F_NOTUSED   = (temp>>5)&1;
				F_OVERFLOW  = (temp>>6)&1;
				F_SIGN      = (temp>>7)&1;

				REG_PC = pull();
				REG_PC += (pull()<<8);
				if (REG_PC==0xFFFF)
					return false;
				REG_PC--;
				F_NOTUSED = 1;
				break;
			case 42:
				REG_PC = pull();
				REG_PC += (pull()<<8);
				
				if (REG_PC==0xFFFF)
					return false;
				break;
			case 43:
				temp = REG_ACC-load(addr)-(1-F_CARRY);
				F_SIGN = (temp>>7)&1;
				F_ZERO = temp&0xFF;
				F_OVERFLOW = ((((REG_ACC^temp)&0x80)!=0 && ((REG_ACC^load(addr))&0x80)!=0)?1:0);
				F_CARRY = (temp<0?0:1);
				REG_ACC = (temp&0xFF);
				if (addrMode!=11)cycleCount+=cycleAdd;
				break;
			case 44:
				F_CARRY = 1;
				break;
			case 45:
				F_DECIMAL = 1;
				break;
			case 46:
				F_INTERRUPT = 1;
				break;
			case 47:
				write(addr, REG_ACC);
				break;
			case 48:
				write(addr, REG_X);
				break;
			case 49:
				write(addr, REG_Y);
				break;
			case 50:
				REG_X = REG_ACC;
				F_SIGN = (REG_ACC>>7)&1;
				F_ZERO = REG_ACC;
				break;
			case 51:
				REG_Y = REG_ACC;
				F_SIGN = (REG_ACC>>7)&1;
				F_ZERO = REG_ACC;
				break;

			case 52:
				REG_X = (REG_SP-0x0100);
				F_SIGN = (REG_SP>>7)&1;
				F_ZERO = REG_X;
				break;

			case 53:
				REG_ACC = REG_X;
				F_SIGN = (REG_X>>7)&1;
				F_ZERO = REG_X;
				break;
			case 54:
				REG_SP = (REG_X+0x0100);
				stackWrap();
				break;
			case 55:
				REG_ACC = REG_Y;
				F_SIGN = (REG_Y>>7)&1;
				F_ZERO = REG_Y;
				break;
			default:
				if (!crash)
				{
					crash = true;
					stopRunning = true;
					this.nes.getGui().showErrorMessage("Game crashed, invalid opcode at address $"+ opaddr.toString(16));
				}
				break;
			}

			if (palEmu)
			{
				palCnt++;
				if (palCnt==5)
				{
					palCnt=0;
					cycleCount++;
				}
			}

			if (asApplet)
			{			
				ppu.cycles = cycleCount*3;
				ppu.emulateCycles();			
			}
			
			if (emulateSound)
			{
				papu.clockFrameCounter(cycleCount);
			}
			
			return true;
		}
		
		private function onLoopComplete(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onLoopComplete);
			
			// Save registers:
			this.REG_ACC_NEW 	= this.REG_ACC;
			this.REG_X_NEW 		= this.REG_X;
			this.REG_Y_NEW 		= this.REG_Y;
			this.REG_STATUS_NEW = this.REG_STATUS;
			this.REG_PC_NEW 	= this.REG_PC;
	
			// Save Status flags:
			this.F_CARRY_NEW	= this.F_CARRY;
			this.F_ZERO_NEW		= (this.F_ZERO==0?1:0);
			this.F_INTERRUPT_NEW= this.F_INTERRUPT;
			this.F_DECIMAL_NEW	= this.F_DECIMAL;
			this.F_BRK_NEW		= this.F_BRK;
			this.F_NOTUSED_NEW	= this.F_NOTUSED;
			this.F_OVERFLOW_NEW	= this.F_OVERFLOW;
			this.F_SIGN_NEW 	= this.F_SIGN;
		}
		
		private	function load(addr:int):int
		{
			return addr<0x2000 ? this.mem[addr&0x7FF] : this.mmap.load(addr);
		}
		
		private	function load16bit(addr:int):int
		{
			return addr<0x1FFF ?
				this.mem[addr&0x7FF] | (this.mem[(addr+1)&0x7FF]<<8)
				:
				this.mmap.load(addr) | (this.mmap.load(addr+1)<<8)
				;
		}
		
		private	function write(addr:int, val:int):void
		{
			if (addr < 0x2000){
				this.mem[addr&0x7FF] = val;
			}else{
				this.mmap.write(addr,val);
			}
		}
	
		public	function requestIrq(type:int):void
		{
			if (irqRequested)
			{
				if (type == IRQ_NORMAL)
					return;
				//trace("too fast irqs. type="+type);
			}
			this.irqRequested = true;
			this.irqType = type;
		}
		
		public	function push(value:int):void
		{
			this.mmap.write(this.REG_SP,value);
			this.REG_SP--;
			this.REG_SP = 0x0100 | (this.REG_SP&0xFF);
		}
	
		public	function stackWrap():void
		{
			this.REG_SP = 0x0100 | (this.REG_SP&0xFF);
		}
	
		public	function pull():int
		{
			this.REG_SP++;
			this.REG_SP = 0x0100 | (this.REG_SP&0xFF);
			return this.mmap.load(this.REG_SP);
		}
	
		public	function pageCrossed(addr1:int, addr2:int):Boolean
		{
			return ((addr1&0xFF00)!=(addr2&0xFF00));
		}
	
		public	function haltCycles(cycles:int):void
		{
			this.cyclesToHalt += cycles;
		}
	
		private	function doNonMaskableInterrupt(status:int):void
		{
	
			var temp:int = this.mmap.load(0x2000); // Read PPU status.
			if ((temp&128)!=0)
			{ // Check whether VBlank Interrupts are enabled
				this.REG_PC_NEW++;
				push((this.REG_PC_NEW>>8)&0xFF);
				push(this.REG_PC_NEW&0xFF);
				//F_INTERRUPT_NEW = 1;
				push(status);
	
				this.REG_PC_NEW = this.mmap.load(0xFFFA) | (this.mmap.load(0xFFFB) << 8);
				this.REG_PC_NEW--;
	
			}
	
	
		}
	
		private	function doResetInterrupt():void
		{
			this.REG_PC_NEW = this.mmap.load(0xFFFC) | (this.mmap.load(0xFFFD) << 8);
			this.REG_PC_NEW--;
		}
	
		private	function doIrq(status:int):void
		{
			this.REG_PC_NEW++;
			push((this.REG_PC_NEW>>8)&0xFF);
			push(this.REG_PC_NEW&0xFF);
			push(status);
			this.F_INTERRUPT_NEW = 1;
			this.F_BRK_NEW = 0;
	
			this.REG_PC_NEW = this.mmap.load(0xFFFE) | (this.mmap.load(0xFFFF) << 8);
			this.REG_PC_NEW--;
		}
	
		private	function getStatus():int
		{
			return (this.F_CARRY_NEW)|(this.F_ZERO_NEW<<1)|(this.F_INTERRUPT_NEW<<2)|(this.F_DECIMAL_NEW<<3)|(this.F_BRK_NEW<<4)|(this.F_NOTUSED_NEW<<5)|(this.F_OVERFLOW_NEW<<6)|(this.F_SIGN_NEW<<7);
		}
	
		private	function setStatus(st:int):void
		{
			this.F_CARRY_NEW     = (st   )&1;
			this.F_ZERO_NEW      = (st>>1)&1;
			this.F_INTERRUPT_NEW = (st>>2)&1;
			this.F_DECIMAL_NEW   = (st>>3)&1;
			this.F_BRK_NEW       = (st>>4)&1;
			this.F_NOTUSED_NEW   = (st>>5)&1;
			this.F_OVERFLOW_NEW  = (st>>6)&1;
			this.F_SIGN_NEW      = (st>>7)&1;
		}
	
		public	function setCrashed(value:Boolean):void
		{
			this.crash = value;
		}
		
		public	function setMapper(mapper:IMemoryMapper):void
		{
			this.mmap = mapper;
		}
		
		public	function destroy():void
		{
			this.nes	= null;
			this.mmap	= null;
		}
	}
}