package com.mobswing.nes.model
{
	public class ChannelDM implements IPapuChannel
	{
		public static const MODE_NORMAL	:int = 0;
		public static const MODE_LOOP	:int = 1;
		public static const MODE_IRQ	:int = 2;
		
		private var papu:PAPU;
		
		private var _isEnabled:Boolean;
		private var hasSample:Boolean;
		public	var irqGenerated:Boolean = false;
		
		private var playMode			:int;
		public	var dmaFrequency		:int;
		private var dmaCounter			:int;
		private var deltaCounter		:int;
		private var playStartAddress	:int;
		private var playAddress			:int;
		private var playLength			:int;
		private var playLengthCounter	:int;
		public	var shiftCounter		:int;
		private var reg4012:int, reg4013:int;
		private var status				:int;
		public	var sample				:int;
		private var dacLsb				:int;
		private var data				:int;

		public	function ChannelDM(papu:PAPU):void
		{
			this.papu = papu;
		}
		
		
		public	function clockDmc():void
		{
			// Only alter DAC value if the sample buffer has data:
			if (hasSample)
			{
				if ((data&1) == 0)
				{
					// Decrement delta:
					if (deltaCounter > 0)
						deltaCounter--;
				}
				else
				{
					// Increment delta:
					if (deltaCounter < 63)
						deltaCounter++;
				}
				// Update sample value:
				sample = _isEnabled ? ((deltaCounter<<1)+dacLsb) : 0;
				// Update shift register:
				data>>=1;
			}
			
			dmaCounter--;
			if (dmaCounter <= 0)
			{
				// No more sample bits.
				hasSample = false;
				endOfSample();
				dmaCounter = 8;
			}
			
			if (irqGenerated)
			{
				papu.nes.cpu.requestIrq(CPU.IRQ_NORMAL);
			}
		}

		private	function endOfSample():void
		{
			if (playLengthCounter==0 && playMode==MODE_LOOP)
			{
				// Start from beginning of sample:
				playAddress = playStartAddress;
				playLengthCounter = playLength;
			}
			
			if (playLengthCounter > 0)
			{
				// Fetch next sample:
				nextSample();
				
				if (playLengthCounter == 0)
				{
					// Last byte of sample fetched, generate IRQ:
					if (playMode == MODE_IRQ)
					{
						// Generate IRQ:
						irqGenerated = true;
					}
				}
			}
		}
		
		private	function nextSample():void
		{
			// Fetch byte:
			data = papu.getNes().getMemoryMapper().load(playAddress);
			papu.getNes().cpu.haltCycles(4);
			
			playLengthCounter--;
			playAddress++;
			if (playAddress > 0xFFFF)
			{
				playAddress = 0x8000;
			}
			hasSample = true;
		}
		
		public	function writeReg(address:int, value:int):void
		{
			if (address == 0x4010)
			{
				// Play mode, DMA Frequency
				if ((value>>6) == 0)
				{
					playMode = MODE_NORMAL;
				}
				else if (((value>>6)&1) == 1)
				{
					playMode = MODE_LOOP;
				}
				else if ((value>>6) == 2)
				{
					playMode = MODE_IRQ;
				}
				
				if ((value&0x80) == 0)
				{
					irqGenerated = false;
				}
				
				dmaFrequency = papu.getDmcFrequency(value&0xF);
			}
			else if (address == 0x4011)
			{
				// Delta counter load register:
				deltaCounter = (value>>1)&63;
				dacLsb = value&1;
				if (papu.userEnableDmc)
				{
					sample = ((deltaCounter<<1)+dacLsb); // update sample value
				}
			}
			else if (address == 0x4012)
			{
				// DMA address load register
				playStartAddress = (value<<6)|0x0C000;
				playAddress = playStartAddress;
				reg4012 = value;
			}
			else if (address == 0x4013)
			{
				// Length of play code
				playLength = (value<<4)+1;
				playLengthCounter = playLength;
				reg4013 = value;
			}
			else if (address == 0x4015)
			{
				// DMC/IRQ Status
				if (((value>>4)&1)==0)
				{
					// Disable:
					playLengthCounter = 0;
				}
				else
				{
					// Restart:
					playAddress = playStartAddress;
					playLengthCounter = playLength;
				}
				irqGenerated = false;
			}
		}
		
		public	function setEnabled(value:Boolean):void
		{
			if ((!_isEnabled) && value)
			{
				playLengthCounter = playLength;
			}
			_isEnabled = value;
		}
		
		public	function isEnabled():Boolean
		{
			return _isEnabled;
		}
		
		public	function getLengthStatus():int
		{
			return ((playLengthCounter==0 || (!_isEnabled)?0:1));
		}
		
		public	function getIrqStatus():int
		{
			return (irqGenerated ? 1 : 0);
		}
		
		public	function reset():void
		{
			_isEnabled = false;
			irqGenerated = false;
			playMode = MODE_NORMAL;
			dmaFrequency = 0;
			dmaCounter = 0;
			deltaCounter = 0;
			playStartAddress = 0;
			playAddress = 0;
			playLength = 0;
			playLengthCounter = 0;
			status = 0;
			sample = 0;
			dacLsb = 0;
			shiftCounter = 0;
			reg4012 = 0;
			reg4013 = 0;
			data = 0;
		}
		
		public	function destroy():void
		{
			papu = null;
		}
	}
}