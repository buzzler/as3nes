package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	public class ChannelSquare implements IPapuChannel
	{
		private var papu:PAPU;
		
		private static var dutyLookup:Vector.<int> = Vector.<int>([
		 0, 1, 0, 0, 0, 0, 0, 0,
		 0, 1, 1, 0, 0, 0, 0, 0,
		 0, 1, 1, 1, 1, 0, 0, 0,
		 1, 0, 0, 1, 1, 1, 1, 1,
		]);		
		private static var impLookup:Vector.<int> = Vector.<int>([
		 1,-1, 0, 0, 0, 0, 0, 0,
		 1, 0,-1, 0, 0, 0, 0, 0,
		 1, 0, 0, 0,-1, 0, 0, 0,
		-1, 0, 1, 0, 0, 0, 0, 0,
		]);
		
		private var sqr1				:Boolean;
		private var _isEnabled			:Boolean;
		private var lengthCounterEnable	:Boolean;
		private var sweepActive			:Boolean;
		private var envDecayDisable		:Boolean;
		private var envDecayLoopEnable	:Boolean;
		private var envReset			:Boolean;
		private var sweepCarry			:Boolean;
		private var updateSweepPeriod	:Boolean;
		
		public	var progTimerCount	:int;
		public	var progTimerMax	:int;
		private var lengthCounter	:int;
		public	var squareCounter	:int;
		private var sweepCounter	:int;
		private var sweepCounterMax	:int;
		private var sweepMode		:int;
		private var sweepShiftAmount:int;
		private var envDecayRate	:int;
		private var envDecayCounter	:int;
		private var envVolume		:int;
		private var masterVolume	:int;
		private var dutyMode		:int;
		private var sweepResult		:int;
		public	var sampleValue		:int;
		private var vol				:int;

		public	function ChannelSquare(papu:PAPU, square1:Boolean):void
		{
			this.papu = papu;
			sqr1 = square1;
		}
		
		public	function clockLengthCounter():void
		{
			if (lengthCounterEnable && lengthCounter>0)
			{
				lengthCounter--;
				if (lengthCounter == 0)
					updateSampleValue();
			}
		}
		
		public	function clockEnvDecay():void
		{
			if (envReset)
			{
				// Reset envelope:
				envReset = false;
				envDecayCounter = envDecayRate + 1;
				envVolume = 0xF;
			}
			else if ((--envDecayCounter) <= 0)
			{
				// Normal handling:
				envDecayCounter = envDecayRate + 1;
				if (envVolume>0)
				{
					envVolume--;
				}
				else
				{
					envVolume = envDecayLoopEnable ? 0xF : 0;
				}
			}
			masterVolume = envDecayDisable ? envDecayRate : envVolume;
			updateSampleValue();
		}
		
		public	function clockSweep():void
		{
			if ((--sweepCounter) <= 0)
			{
				sweepCounter = sweepCounterMax + 1;
				if (sweepActive && (sweepShiftAmount>0) && (progTimerMax>7))
				{
					// Calculate result from shifter:
					sweepCarry = false;
					if (sweepMode == 0)
					{
						progTimerMax += (progTimerMax >> sweepShiftAmount);
						if (progTimerMax > 4095)
						{
							progTimerMax = 4095;
							sweepCarry = true;
						}
					}
					else
					{
						progTimerMax = progTimerMax - ((progTimerMax >> sweepShiftAmount) - (sqr1 ? 1 : 0));
					}
				}
			}
			
			if (updateSweepPeriod)
			{
				updateSweepPeriod = false;
				sweepCounter = sweepCounterMax + 1;
			}
		}
		
		public	function updateSampleValue():void
		{
			if (_isEnabled && (lengthCounter>0) && (progTimerMax>7))
			{
				if (sweepMode==0 && (progTimerMax + (progTimerMax >> sweepShiftAmount)) > 4095)
				{
					sampleValue = 0;
				}
				else
				{
					sampleValue = masterVolume*dutyLookup[(dutyMode<<3)+squareCounter];
				}
			}
			else
			{
				sampleValue = 0;
			}
		}
		
		public	function writeReg(address:int, value:int):void
		{
			var addrAdd:int = (sqr1 ? 0 : 4);
			if (address == (0x4000+addrAdd))
			{
				// Volume/Envelope decay:
				envDecayDisable = ((value&0x10)!=0);
				envDecayRate = value & 0xF;
				envDecayLoopEnable = ((value&0x20)!=0);
				dutyMode = (value>>6)&0x3;
				lengthCounterEnable = ((value&0x20)==0);
				masterVolume = envDecayDisable?envDecayRate:envVolume;
				updateSampleValue();
			}
			else if (address == (0x4001+addrAdd))
			{
				// Sweep:
				sweepActive = ((value&0x80)!=0);
				sweepCounterMax = ((value>>4)&7);
				sweepMode = (value>>3)&1;
				sweepShiftAmount = value&7;
				updateSweepPeriod = true;
			}
			else if (address == (0x4002+addrAdd))
			{
				// Programmable timer:
				progTimerMax &= 0x700;
				progTimerMax |= value;
			}
			else if (address == (0x4003+addrAdd))
			{
				// Programmable timer, length counter
				progTimerMax &= 0xFF;
				progTimerMax |= ((value&0x7)<<8);
				
				if (_isEnabled)
				{
					lengthCounter = papu.getLengthMax(value&0xF8);
				}
				envReset  = true;
			}
		}

		public	function setEnabled(value:Boolean):void
		{
			_isEnabled = value;
			if (!value)
				lengthCounter = 0;
			updateSampleValue();
		}

		public	function isEnabled():Boolean
		{
			return _isEnabled;
		}

		public	function getLengthStatus():int
		{
			return ((lengthCounter==0 || !_isEnabled) ? 0 : 1);
		}

		public	function reset():void
		{
			progTimerCount = 0;
			progTimerMax = 0;
			lengthCounter = 0;
			squareCounter = 0;
			sweepCounter = 0;
			sweepCounterMax = 0;
			sweepMode = 0;
			sweepShiftAmount = 0;
			envDecayRate = 0;
			envDecayCounter = 0;
			envVolume = 0;
			masterVolume = 0;
			dutyMode = 0;
			vol = 0;
			
			_isEnabled = false;
			lengthCounterEnable = false;
			sweepActive = false;
			sweepCarry = false;
			envDecayDisable = false;
			envDecayLoopEnable = false;
		}

		public	function destroy():void
		{
			papu = null;
		}
	}
}