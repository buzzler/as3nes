package com.mobswing.model
{
	public class ChannelTriangle implements IPapuChannel
	{
		private var papu:PAPU;
		
		private var _isEnabled			:Boolean;
		public	var sampleCondition		:Boolean;
		public	var lengthCounterEnable	:Boolean;
		private var lcHalt				:Boolean;
		private var lcControl			:Boolean;
		
		public	var progTimerCount	:int;
		public	var progTimerMax	:int;
		public	var triangleCounter	:int;
		public	var lengthCounter	:int;
		public	var linearCounter	:int;
		private var lcLoadValue		:int;
		public	var sampleValue		:int;
		private var tmp				:int;

		public	function ChannelTriangle(papu:PAPU):void
		{
			this.papu = papu;
		}
		
		public	function clockLengthCounter():void
		{
			if (lengthCounterEnable && lengthCounter>0)
			{
				lengthCounter--;
				if (lengthCounter == 0)
				{
					updateSampleCondition();
				}
			}
		}
		
		public	function clockLinearCounter():void
		{
			if (lcHalt)
			{
				// Load:
				linearCounter = lcLoadValue;
				updateSampleCondition();
			}
			else if (linearCounter > 0)
			{
				// Decrement:
				linearCounter--;
				updateSampleCondition();
			}
			
			if (!lcControl)
			{
				// Clear halt flag:
				lcHalt = false;
			}
		}
		
		public	function getLengthStatus():int
		{
			return ((lengthCounter==0 || !_isEnabled) ? 0 : 1);
		}
		
		public	function readReg(address:int):int
		{
			return 0;
		}
		
		public	function writeReg(address:int, value:int):void
		{
			if (address == 0x4008)
			{
				// New values for linear counter:
				lcControl 	= (value&0x80)!=0;
				lcLoadValue =  value&0x7F;
				
				// Length counter enable:
				lengthCounterEnable = !lcControl;
			}
			else if (address == 0x400A)
			{
				// Programmable timer:
				progTimerMax &= 0x700;
				progTimerMax |= value;
			}
			else if (address == 0x400B)
			{
				// Programmable timer, length counter
				progTimerMax &= 0xFF;
				progTimerMax |= ((value&0x07)<<8);
				lengthCounter = papu.getLengthMax(value&0xF8);
				lcHalt = true;
			}
			updateSampleCondition();
		}
		
		public	function clockProgrammableTimer(nCycles:int):void
		{
			if (progTimerMax > 0)
			{
				progTimerCount+=nCycles;
				while ((progTimerMax>0) && (progTimerCount>=progTimerMax))
				{
					progTimerCount-=progTimerMax;
					if (_isEnabled && (lengthCounter>0) && (linearCounter>0))
					{
						clockTriangleGenerator();
					}
				}
			}
		}
		
		public	function clockTriangleGenerator():void
		{
			triangleCounter++;
			triangleCounter &= 0x1F;
		}
		
		public	function setEnabled(value:Boolean):void
		{
			_isEnabled = value;
			if (!value)
				lengthCounter = 0;
			updateSampleCondition();
		}
		
		public	function isEnabled():Boolean
		{
			return _isEnabled;
		}
	
		public	function updateSampleCondition():void
		{
			sampleCondition = _isEnabled	&& (progTimerMax>7) && (linearCounter>0) &&	(lengthCounter>0);
		}
	
		public	function reset():void
		{
			progTimerCount = 0;
			progTimerMax = 0;
			triangleCounter = 0;
			_isEnabled = false;
			sampleCondition = false;
			lengthCounter = 0;
			lengthCounterEnable = false;
			linearCounter = 0;
			lcLoadValue = 0;
			lcHalt = true;
			lcControl = false;
			tmp = 0;
			sampleValue = 0xF;
		}
		
		public	function destroy():void
		{
			papu = null;
		}
	}
}