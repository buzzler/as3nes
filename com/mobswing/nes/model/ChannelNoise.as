package com.mobswing.nes.model
{
	public class ChannelNoise implements IPapuChannel
	{
		private var papu:PAPU;
		
		public	var _isEnabled			:Boolean;
		public	var envDecayDisable		:Boolean;
		public	var envDecayLoopEnable	:Boolean;
		public	var lengthCounterEnable	:Boolean;
		public	var envReset			:Boolean;
		public	var shiftNow			:Boolean;
		
		public	var lengthCounter	:int;
		public	var progTimerCount	:int;
		public	var progTimerMax	:int;
		public	var envDecayRate	:int;
		public	var envDecayCounter	:int;
		public	var envVolume		:int;
		public	var masterVolume	:int;
		public	var shiftReg		:int;
		public	var randomBit		:int;
		public	var randomMode		:int;
		public	var sampleValue		:int;
		public	var accValue		:Number = 0;
		public	var accCount		:Number = 1;
		public	var tmp				:int;
		
		
		public	function ChannelNoise(papu:PAPU):void
		{
			this.papu = papu;
			shiftReg = 1<<14;
		}
		
		public	function clockLengthCounter():void
		{
			if (lengthCounterEnable && (lengthCounter>0))
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
		
		public	function updateSampleValue():void
		{
			if (_isEnabled && (lengthCounter>0))
			{
				sampleValue = randomBit * masterVolume;
			}
		}
		
		public	function writeReg(address:int, value:int):void
		{
			if (address == 0x400C)
			{
				// Volume/Envelope decay:
				envDecayDisable = ((value&0x10)!=0);
				envDecayRate = value&0xF;
				envDecayLoopEnable = ((value&0x20)!=0);
				lengthCounterEnable = ((value&0x20)==0);
				masterVolume = envDecayDisable?envDecayRate:envVolume;
			}
			else if (address == 0x400E)
			{
				// Programmable timer:
				progTimerMax = papu.getNoiseWaveLength(value&0xF);
				randomMode = value>>7;
			}
			else if (address == 0x400F)
			{
				// Length counter
				lengthCounter = papu.getLengthMax(value&248);
				envReset = true;
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
			_isEnabled = false;
			lengthCounter = 0;
			lengthCounterEnable = false;
			envDecayDisable = false;
			envDecayLoopEnable = false;
			shiftNow = false;
			envDecayRate = 0;
			envDecayCounter = 0;
			envVolume = 0;
			masterVolume = 0;
			shiftReg = 1;
			randomBit = 0;
			randomMode = 0;
			sampleValue = 0;
			tmp = 0;
		}
		
		public	function destroy():void
		{
			papu = null;
		}
	}
}