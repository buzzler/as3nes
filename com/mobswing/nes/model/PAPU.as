package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	import flash.media.SoundMixer;
	
	public class PAPU
	{
		public	var nes		:Nes;
		private var cpuMem	:Memory;
		private var mixer	:SoundMixer;
		private var line	:SourceDataLine;
	
		private var square1	:ChannelSquare;
		private var square2	:ChannelSquare;
		private var triangle:ChannelTriangle;
		private var noise	:ChannelNoise;
		private var dmc		:ChannelDM;
	
		private var lengthLookup			:Vector.<int>;	//int
		private var dmcFreqLookup			:Vector.<int>;
		private var noiseWavelengthLookup	:Vector.<int>;
		private var square_table			:Vector.<int>;
		private var tnd_table				:Vector.<int>;
		private var ismpbuffer				:Vector.<int>;
		private var sampleBuffer			:Vector.<Number>;	//byte
	
		private var frameIrqCounter		:int;
		private var frameIrqCounterMax	:int;
		private var initCounter			:int;
		private var channelEnableValue	:int;
	
		private var b1:int, b2:int, b3:int, b4:int;
		private var bufferSize			:int = 2048;
		public	var bufferIndex			:int;
		private var sampleRate			:int = 44100;
	
		private var frameIrqEnabled	:Boolean;
		private var frameIrqActive	:Boolean;
		private var frameClockNow	:Boolean;
		private var startedPlaying	:Boolean = false;
		private var recordOutput	:Boolean = false;
		private var stereo			:Boolean = true;
		private var initingHardware	:Boolean = false;
	
		private var userEnableSquare1		:Boolean = true;
		private var userEnableSquare2		:Boolean = true;
		private	var userEnableTriangle		:Boolean = true;
		private	var userEnableNoise			:Boolean = true;
		public	var userEnableDmc			:Boolean = true;
	
		private var masterFrameCounter	:int;
		private var derivedFrameCounter	:int;
		private var countSequence		:int;
		private var sampleTimer			:int;
		private var frameTime			:int;
		private var sampleTimerMax		:int;
		private var sampleCount			:int;
		private var triValue			:int = 0;
		private var sampleValueL:int, sampleValueR:int;
	
		private var smpSquare1:int, smpSquare2:int, smpTriangle:int, smpNoise:int, smpDmc:int;
		private var accCount:int;
		private var sq_index:int, tnd_index:int;
	
		private var prevSampleL:int = 0, prevSampleR:int = 0;
		private var smpAccumL:int = 0, smpAccumR:int = 0;
		private var smpDiffL:int = 0, smpDiffR:int = 0;

		private var dacRange:int = 0;
		private var dcValue	:int = 0;

		private var masterVolume:int;

		private var panning:Vector.<int>;

		private var stereoPosLSquare1	:int;
		private var stereoPosLSquare2	:int;
		private var stereoPosLTriangle	:int;
		private var stereoPosLNoise		:int;
		private var stereoPosLDMC		:int;
		private var stereoPosRSquare1	:int;
		private var stereoPosRSquare2	:int;
		private var stereoPosRTriangle	:int;
		private var stereoPosRNoise		:int;
		private var stereoPosRDMC		:int;
	
		private var extraCycles	:int;
		private var maxCycles	:int;
	
	
		public	function PAPU(nes:Nes):void
		{
			this.nes = nes;

			cpuMem = nes.getCpuMemory();
	
			setSampleRate(sampleRate,false);
			sampleBuffer = new Vector.<Number>(bufferSize*(stereo ? 2:1));
			ismpbuffer = new Vector.<int>(bufferSize*(stereo ? 2:1));
			bufferIndex = 0;
			frameIrqEnabled = false;
			initCounter = 2048;
	
			square1 = new ChannelSquare(this,true);
			square2 = new ChannelSquare(this,false);
			triangle = new ChannelTriangle(this);
			noise = new ChannelNoise(this);
			dmc = new ChannelDM(this);
	
			masterVolume = 256;
			panning = Vector.<int>([
				 80,
				170,
				100,
				150,
				128
			]);
			setPanning(panning);
	
			// Initialize lookup tables:
			initLengthLookup();
			initDmcFrequencyLookup();
			initNoiseWavelengthLookup();
			initDACtables();
	
			frameIrqEnabled = false;
			frameIrqCounterMax = 4;
	
		}
	
		public	function stateLoad(buf:ByteBuffer):void
		{
		}
	
		public	function stateSave(buf:ByteBuffer):void
		{
		}
	
		public	function start():void
		{
			//System.out.println("* Starting PAPU lines.");
			if (line!=null && line.isActive())
			{
				//System.out.println("* Already running.");
				return;
			}
	
			bufferIndex = 0;
			//Mixer.Info[] mixerInfo = AudioSystem.getMixerInfo();
			
			//if(mixerInfo==null || mixerInfo.length==0){
			if (SoundMixer.areSoundsInaccessible())
			{
				//System.out.println("No audio mixer available, sound disabled.");
				Globals.enableSound = false;
				return;
			}
			/* mixer = AudioSystem.getMixer(mixerInfo[1]);
			AudioFormat audioFormat = new AudioFormat(sampleRate,16,(stereo?2:1),true,false);
			DataLine.Info info = new DataLine.Info(SourceDataLine.class,audioFormat,sampleRate);
	
			try{
				line = (SourceDataLine)AudioSystem.getLine(info);
				line.open(audioFormat);
				line.start();
	
			}catch(Exception e){
				//System.out.println("Couldn't get sound lines.");
			}*/
			line = new SourceDataLine();
			line.start();
		}
	
		public	function getNes():Nes
		{
			return nes;
		}
	
		public	function readReg(address:int):int
		{
			// Read 0x4015:
			var tmp:int = 0;
			tmp |= (square1.getLengthStatus()   );
			tmp |= (square2.getLengthStatus() <<1);
			tmp |= (triangle.getLengthStatus()<<2);
			tmp |= (noise.getLengthStatus()   <<3);
			tmp |= (dmc.getLengthStatus()     <<4);
			tmp |= (((frameIrqActive && frameIrqEnabled)?1:0)<<6);
			tmp |= (dmc.getIrqStatus()        <<7);
	
			frameIrqActive = false;
			dmc.irqGenerated = false;
			
			////System.out.println("$4015 read. Value = "+Misc.bin8(tmp)+" countseq = "+countSequence);
			return tmp & 0xFFFF;
		}
	
		public	function writeReg(address:int, value:int):void
		{
			if (address>=0x4000 && address<0x4004)
			{
				// Square Wave 1 Control
				square1.writeReg(address,value);
				////System.out.println("Square Write");
			}
			else if (address>=0x4004 && address<0x4008)
			{
				// Square 2 Control
				square2.writeReg(address,value);
			}
			else if (address>=0x4008 && address<0x400C)
			{
				// Triangle Control
				triangle.writeReg(address,value);
			}
			else if (address>=0x400C && address<=0x400F)
			{
				// Noise Control
				noise.writeReg(address,value);
			}
			else if (address == 0x4010)
			{
				// DMC Play mode & DMA frequency
				dmc.writeReg(address,value);
			}
			else if (address == 0x4011)
			{
				// DMC Delta Counter
				dmc.writeReg(address,value);
			}
			else if (address == 0x4012)
			{
				// DMC Play code starting address
				dmc.writeReg(address,value);
			}
			else if (address == 0x4013)
			{
				// DMC Play code length
				dmc.writeReg(address,value);
			}
			else if (address == 0x4015)
			{
				// Channel enable
				updateChannelEnable(value);
	
				if(value!=0 && initCounter>0)
				{
					// Start hardware initialization
					initingHardware = true;
				}
				// DMC/IRQ Status
				dmc.writeReg(address,value);
			}
			else if (address == 0x4017)
			{
				// Frame counter control
				countSequence = (value>>7)&1;
				masterFrameCounter = 0;
				frameIrqActive = false;
	
				if (((value>>6)&0x1)==0)
				{
					frameIrqEnabled = true;
				}
				else
				{
					frameIrqEnabled = false;
				}
	
				if (countSequence == 0)
				{
					// NTSC:
					frameIrqCounterMax = 4;
					derivedFrameCounter = 4;
				}
				else
				{
					// PAL:
					frameIrqCounterMax = 5;
					derivedFrameCounter = 0;
					frameCounterTick();
				}
			}
		}
	
		public	function resetCounter():void
		{
			if (countSequence==0)
			{
				derivedFrameCounter = 4;
			}
			else
			{
				derivedFrameCounter = 0;
			}
		}
	
	
		public	function updateChannelEnable(value:int):void
		{
			channelEnableValue = value;
			square1.setEnabled(userEnableSquare1 && (value&1)!=0);
			square2.setEnabled(userEnableSquare2 && (value&2)!=0);
			triangle.setEnabled(userEnableTriangle && (value&4)!=0);
			noise.setEnabled(userEnableNoise && (value&8)!=0);
			dmc.setEnabled(userEnableDmc && (value&16)!=0);
		}

		public	function clockFrameCounter(nCycles:int):void
		{
			if (initCounter > 0)
			{
				if (initingHardware)
				{
					initCounter -= nCycles;
					if(initCounter <= 0)
						initingHardware = false;
					return;
				}
			}
			// Don't process ticks beyond next sampling:
			nCycles += extraCycles;
			maxCycles = sampleTimerMax-sampleTimer;
			if ((nCycles<<10) > maxCycles)
			{
				extraCycles = ((nCycles<<10) - maxCycles)>>10;
				nCycles -= extraCycles;
			}
			else
			{
				extraCycles = 0;
			}
			// Clock DMC:
			if (dmc.isEnabled())
			{
				dmc.shiftCounter-=(nCycles<<3);
				while (dmc.shiftCounter<=0 && dmc.dmaFrequency>0)
				{
					dmc.shiftCounter += dmc.dmaFrequency;
					dmc.clockDmc();
				}
			}
	
			// Clock Triangle channel Prog timer:
			if (triangle.progTimerMax>0)
			{
				triangle.progTimerCount -= nCycles;
				while (triangle.progTimerCount <= 0)
				{
					triangle.progTimerCount += triangle.progTimerMax+1;
					if (triangle.linearCounter>0 && triangle.lengthCounter>0)
					{
						triangle.triangleCounter++;
						triangle.triangleCounter &= 0x1F;
	
						if (triangle.isEnabled())
						{
							if (triangle.triangleCounter>=0x10)
							{
								// Normal value.
								triangle.sampleValue = (triangle.triangleCounter&0xF);
							}
							else
							{
								// Inverted value.
								triangle.sampleValue = (0xF - (triangle.triangleCounter&0xF));
							}
							triangle.sampleValue <<= 4;
						}
					}
				}
			}
	
			// Clock Square channel 1 Prog timer:
			square1.progTimerCount -= nCycles;
			if (square1.progTimerCount <= 0)
			{
				square1.progTimerCount += (square1.progTimerMax+1)<<1;
				square1.squareCounter++;
				square1.squareCounter&=0x7;
				square1.updateSampleValue();
			}
	
			// Clock Square channel 2 Prog timer:
			square2.progTimerCount -= nCycles;
			if (square2.progTimerCount <= 0)
			{
				square2.progTimerCount += (square2.progTimerMax+1)<<1;
				square2.squareCounter++;
				square2.squareCounter&=0x7;
				square2.updateSampleValue();
			}
			// Clock noise channel Prog timer:
			var acc_c:int = nCycles;
			if (noise.progTimerCount-acc_c > 0)
			{
				// Do all cycles at once:
				noise.progTimerCount -= acc_c;
				noise.accCount       += acc_c;
				noise.accValue       += acc_c * noise.sampleValue;
			}
			else
			{
				// Slow-step:
				while ((acc_c--) > 0)
				{
					if (--noise.progTimerCount <= 0 && noise.progTimerMax>0)
					{
						// Update noise shift register:
						noise.shiftReg <<= 1;
						noise.tmp = (((noise.shiftReg << (noise.randomMode==0?1:6)) ^ noise.shiftReg) & 0x8000 );
						if (noise.tmp != 0)
						{
							// Sample value must be 0.
							noise.shiftReg |= 0x01;
							noise.randomBit = 0;
							noise.sampleValue = 0;
						}
						else
						{
							// Find sample value:
							noise.randomBit = 1;
							if (noise.isEnabled() && noise.lengthCounter>0)
							{
								noise.sampleValue = noise.masterVolume;
							}
							else
							{
								noise.sampleValue = 0;
							}
						}
						noise.progTimerCount += noise.progTimerMax;
					}
					noise.accValue += noise.sampleValue;
					noise.accCount++;
				}
			}
	
			// Frame IRQ handling:
			if (frameIrqEnabled && frameIrqActive)
			{
				nes.cpu.requestIrq(CPU.IRQ_NORMAL);
			}
			// Clock frame counter at double CPU speed:
			masterFrameCounter+=(nCycles<<1);
			if (masterFrameCounter>=frameTime)
			{
				// 240Hz tick:
				masterFrameCounter -= frameTime;
				frameCounterTick();
			}
			
			// Accumulate sample value:
			accSample(nCycles);
	
			// Clock sample timer:
			sampleTimer += nCycles<<10;
			if (sampleTimer >= sampleTimerMax)
			{
				// Sample channels:
				sample();
				sampleTimer -= sampleTimerMax;
			}
		}
		
		private	function accSample(cycles:int):void
		{
			// Special treatment for triangle channel - need to interpolate.
			if (triangle.sampleCondition)
			{
				triValue = (triangle.progTimerCount<<4) / (triangle.progTimerMax+1);
				if (triValue>16)
					triValue = 16;
				if (triangle.triangleCounter >= 16)
				{
					triValue = 16-triValue;
				}
				// Add non-interpolated sample value:
				triValue += triangle.sampleValue;
			}
			
			// Now sample normally:
			if (cycles == 2)
			{
				smpTriangle += triValue				<< 1;
				smpDmc      += dmc.sample			<< 1;
				smpSquare1  += square1.sampleValue	<< 1;
				smpSquare2  += square2.sampleValue	<< 1;
				accCount    += 2;
			}
			else if (cycles == 4)
			{
				smpTriangle += triValue				<< 2;
				smpDmc      += dmc.sample			<< 2;
				smpSquare1  += square1.sampleValue	<< 2;
				smpSquare2  += square2.sampleValue	<< 2;
				accCount    += 4;
			}
			else
			{
				smpTriangle += cycles * triValue;
				smpDmc      += cycles * dmc.sample;
				smpSquare1  += cycles * square1.sampleValue;
				smpSquare2  += cycles * square2.sampleValue;
				accCount    += cycles;
			}
		}
		
		public	function frameCounterTick():void
		{
			derivedFrameCounter++;
			if(derivedFrameCounter >= frameIrqCounterMax)
			{
				derivedFrameCounter = 0;
			}
			
			if (derivedFrameCounter==1 || derivedFrameCounter==3)
			{
				// Clock length & sweep:
				triangle.clockLengthCounter();
				square1.clockLengthCounter();
				square2.clockLengthCounter();
				noise.clockLengthCounter();
				square1.clockSweep();
				square2.clockSweep();
			}
	
			if (derivedFrameCounter >= 0 && derivedFrameCounter < 4)
			{
				// Clock linear & decay:			
				square1.clockEnvDecay();
				square2.clockEnvDecay();
				noise.clockEnvDecay();
				triangle.clockLinearCounter();
			}
			
			if (derivedFrameCounter == 3 && countSequence==0)
			{
				// Enable IRQ:
				frameIrqActive = true;
			}
			// End of 240Hz tick
		}
	
		public	function sample():void
		{
			if (accCount > 0)
			{
				smpSquare1 	<<= 4;
				smpSquare1  /= accCount;
	
				smpSquare2 	<<= 4;
				smpSquare2  /= accCount;
	
				smpTriangle /= accCount;
	
				smpDmc 		<<= 4;
				smpDmc      /= accCount;
				
				accCount    = 0;
			}
			else
			{
				smpSquare1  = square1.sampleValue   << 4;
				smpSquare2  = square2.sampleValue   << 4;
				smpTriangle = triangle.sampleValue      ;
				smpDmc      = dmc.sample            << 4;
			}
			
			smpNoise = int((noise.accValue<<4)/noise.accCount);
			noise.accValue = smpNoise>>4;
			noise.accCount = 1;
	
			if (stereo)
			{
				// Left channel:
				sq_index  = (smpSquare1 *  stereoPosLSquare1 + smpSquare2 * stereoPosLSquare2) >> 8;
				tnd_index = (3 * smpTriangle * stereoPosLTriangle + (smpNoise<<1) * stereoPosLNoise + smpDmc * stereoPosLDMC) >> 8;
				if (sq_index >= square_table.length)
					sq_index = square_table.length-1;
				if (tnd_index >= tnd_table.length)
					tnd_index = tnd_table.length-1;
				sampleValueL = square_table[sq_index] + tnd_table[tnd_index] - dcValue;
	
				// Right channel:
				sq_index  = (smpSquare1 * stereoPosRSquare1 + smpSquare2 * stereoPosRSquare2) >> 8;
				tnd_index = (3 * smpTriangle * stereoPosRTriangle + (smpNoise<<1) * stereoPosRNoise + smpDmc * stereoPosRDMC) >> 8;			
				if (sq_index >= square_table.length)
					sq_index = square_table.length-1;
				if (tnd_index >= tnd_table.length)
					tnd_index = tnd_table.length-1;			
				sampleValueR = square_table[sq_index] + tnd_table[tnd_index] - dcValue;
			}
			else
			{
				// Mono sound:
				sq_index = smpSquare1 + smpSquare2;
				tnd_index = 3*smpTriangle + 2*smpNoise + smpDmc;
				if (sq_index >= square_table.length)
					sq_index = square_table.length - 1;
				if (tnd_index >= tnd_table.length)
					tnd_index = tnd_table.length - 1;
				sampleValueL = 3 * (square_table[sq_index] + tnd_table[tnd_index] - dcValue);
				sampleValueL >>= 2;
			}
			// Remove DC from left channel:
			smpDiffL     = sampleValueL - prevSampleL;
			prevSampleL += smpDiffL;
			smpAccumL   += smpDiffL - (smpAccumL >> 10);
			sampleValueL = smpAccumL;
			
			if (stereo)
			{
				// Remove DC from right channel:
				smpDiffR 	 = sampleValueR - prevSampleR;
				prevSampleR += smpDiffR;
				smpAccumR 	+= smpDiffR - (smpAccumR >> 10);
				sampleValueR = smpAccumR;
	
				// Write:
				if (bufferIndex+2 < sampleBuffer.length)
				{
					/*
					sampleBuffer[bufferIndex++] = ((sampleValueL   ) & 0xFF);
					sampleBuffer[bufferIndex++] = ((sampleValueL>>8) & 0xFF);
					sampleBuffer[bufferIndex++] = ((sampleValueR   ) & 0xFF);
					sampleBuffer[bufferIndex++] = ((sampleValueR>>8) & 0xFF);
					*/
					sampleBuffer[bufferIndex++] = Number((sampleValueL & 0xFFFF) / 32767) * Globals.volume;
					sampleBuffer[bufferIndex++] = Number((sampleValueR & 0xFFFF) / 32767) * Globals.volume;
				}
			}
			else
			{
				// Write:
				if (bufferIndex < sampleBuffer.length)
				{
					/*
					sampleBuffer[bufferIndex++] = ((sampleValueL   ) & 0xFF);
					sampleBuffer[bufferIndex++] = ((sampleValueL>>8) & 0xFF);
					*/
					sampleBuffer[bufferIndex++] = (sampleValueL & 0xFFFF) / 32767 * Globals.volume;
				}
			}
			// Reset sampled values:
			smpSquare1  = 0;
			smpSquare2  = 0;
			smpTriangle = 0;
			smpDmc      = 0;
		}
	
		// Writes the sound buffer to the output line:
		public	function writeBuffer():void
		{
			if (line == null)
				return;
//			bufferIndex -= (bufferIndex%(stereo?2:1));
			line.write(sampleBuffer,0,bufferIndex, stereo);
			bufferIndex = 0;
		}
	
		public	function stop():void
		{
			if (line == null)
			{
				// No line to close. Probably lack of sound card.
				return;
			}
	
			if (line!=null && line.isOpen() && line.isActive())
			{
				line.close();
			}
			
			// Lose line:
			line = null;
		}
	
		public	function getSampleRate():int
		{
			return sampleRate;
		}
	
		public	function reset():void
		{
			setSampleRate(sampleRate,false);
			updateChannelEnable(0);
			masterFrameCounter = 0;
			derivedFrameCounter = 0;
			countSequence = 0;
			sampleCount = 0;
			initCounter = 2048;
			frameIrqEnabled = false;
			initingHardware = false;
	
			resetCounter();
	
			square1.reset();
			square2.reset();
			triangle.reset();
			noise.reset();
			dmc.reset();
	
			bufferIndex = 0;
			accCount = 0;
			smpSquare1 = 0;
			smpSquare2 = 0;
			smpTriangle = 0;
			smpNoise = 0;
			smpDmc = 0;
	
			frameIrqEnabled = false;
			frameIrqCounterMax = 4;
	
			channelEnableValue = 0xFF;
			b1 = 0;
			b2 = 0;
			startedPlaying = false;
			sampleValueL = 0;
			sampleValueR = 0;
			prevSampleL = 0;
			prevSampleR = 0;
			smpAccumL = 0;
			smpAccumR = 0;
			smpDiffL = 0;
			smpDiffR = 0;
		}
	
		public	function getLengthMax(value:int):int
		{
			return lengthLookup[value>>3];
		}
	
		public	function getDmcFrequency(value:int):int
		{
			if (value>=0 && value<0x10)
			{
				return dmcFreqLookup[value];
			}
			return 0;
		}
	
		public	function getNoiseWaveLength(value:int):int
		{
			if (value>=0 && value<0x10)
			{
				return noiseWavelengthLookup[value];
			}
			return 0;
		}
	
		public	function setSampleRate(rate:int, restart:Boolean):void
		{
			var cpuRunning:Boolean = nes.isRunning();
			if (cpuRunning)
			{
				nes.stopEmulation();
			}
	
			sampleRate = rate;
			sampleTimerMax = int((1024.0*Globals.CPU_FREQ_NTSC*Globals.preferredFrameRate) / (sampleRate*60.0));
			
			frameTime = int((14915.0*Number(Globals.preferredFrameRate)) / 60.0);
	
			sampleTimer = 0;
			bufferIndex = 0;
			
			if (restart)
			{
				stop();
				start();
			}
	
			if (cpuRunning)
			{
				nes.startEmulation();
			}
		}
	
		public	function setStereo(s:Boolean, restart:Boolean):void
		{
			if (stereo == s)
			{
				return;
			}
	
			var running:Boolean = nes.isRunning();
			nes.stopEmulation();
	
			stereo = s;
			if (stereo)
			{
				sampleBuffer = new Vector.<Number>(bufferSize*2);
			}
			else
			{
				sampleBuffer = new Vector.<Number>(bufferSize*2);
			}
	
			if (restart)
			{
				stop();
				start();
			}
	
			if (running)
			{
				nes.startEmulation();
			}
		}
	
		public	function getPapuBufferSize():int
		{
			return sampleBuffer.length;
		}
	
		public	function setChannelEnabled(channel:int, value:Boolean):void
		{
			if (channel == 0)
			{
				userEnableSquare1 = value;
			}
			else if (channel == 1)
			{
				userEnableSquare2 = value;
			}
			else if (channel == 2)
			{
				userEnableTriangle = value;
			}
			else if (channel == 3)
			{
				userEnableNoise = value;
			}
			else
			{
				userEnableDmc = value;
			}
			updateChannelEnable(channelEnableValue);
		}
	
		public	function setPanning(pos:Vector.<int>):void
		{
			for (var i:int = 0 ; i < 5 ; i++)
			{
				panning[i] = pos[i];
			}
			updateStereoPos();
		}
		
		public	function setMasterVolume(value:int):void
		{
			if (value < 0)
				value = 0;
			if (value > 256)
				value = 256;
			masterVolume = value;
			updateStereoPos();
		}
	
		public	function updateStereoPos():void
		{
			stereoPosLSquare1  = (panning[0]*masterVolume)>>8;
			stereoPosLSquare2  = (panning[1]*masterVolume)>>8;
			stereoPosLTriangle = (panning[2]*masterVolume)>>8;
			stereoPosLNoise    = (panning[3]*masterVolume)>>8;
			stereoPosLDMC      = (panning[4]*masterVolume)>>8;
			
			stereoPosRSquare1 	= masterVolume - stereoPosLSquare1;
			stereoPosRSquare2 	= masterVolume - stereoPosLSquare2;
			stereoPosRTriangle 	= masterVolume - stereoPosLTriangle;
			stereoPosRNoise 	= masterVolume - stereoPosLNoise;
			stereoPosRDMC 		= masterVolume - stereoPosLDMC;
		}
	
		public	function getLine():SourceDataLine
		{
			return line;
		}
	
		public	function isRunning():Boolean
		{
			return (line!=null && line.isActive());
		}
	
		public	function getMillisToAvailableAbove(target_avail:int):int
		{
			var time:Number;
			var cur_avail:int;
			if ((cur_avail=line.available()) >= target_avail)
				return 0;
	
			time  = (target_avail-cur_avail)/sampleRate;
			time /= (stereo ? 2:1);
	
			// round down to nearest 10 ms:
			time /= 10;
			time *= 10;
	
			return int(time);
		}
	
		public	function getBufferPos():int
		{
			return bufferIndex;
		}
	
		public	function initLengthLookup():void
		{
			lengthLookup = Vector.<int>([
				0x0A, 0xFE,
				0x14, 0x02,
				0x28, 0x04,
				0x50, 0x06,
				0xA0, 0x08,
				0x3C, 0x0A,
				0x0E, 0x0C,
				0x1A, 0x0E,
				0x0C, 0x10,
				0x18, 0x12,
				0x30, 0x14,
				0x60, 0x16,
				0xC0, 0x18,
				0x48, 0x1A,
				0x10, 0x1C,
				0x20, 0x1E
			]);
		}
	
		public	function initDmcFrequencyLookup():void
		{
			dmcFreqLookup = new Vector.<int>(16)
			dmcFreqLookup[0x0] = 0xD60;
			dmcFreqLookup[0x1] = 0xBE0;
			dmcFreqLookup[0x2] = 0xAA0;
			dmcFreqLookup[0x3] = 0xA00;
			dmcFreqLookup[0x4] = 0x8F0;
			dmcFreqLookup[0x5] = 0x7F0;
			dmcFreqLookup[0x6] = 0x710;
			dmcFreqLookup[0x7] = 0x6B0;
			dmcFreqLookup[0x8] = 0x5F0;
			dmcFreqLookup[0x9] = 0x500;
			dmcFreqLookup[0xA] = 0x470;
			dmcFreqLookup[0xB] = 0x400;
			dmcFreqLookup[0xC] = 0x350;
			dmcFreqLookup[0xD] = 0x2A0;
			dmcFreqLookup[0xE] = 0x240;
			dmcFreqLookup[0xF] = 0x1B0;
			//for(int i=0;i<16;i++)dmcFreqLookup[i]/=8;
		}
		
		public	function initNoiseWavelengthLookup():void
		{
			noiseWavelengthLookup = new Vector.<int>(16);
	
			noiseWavelengthLookup[0x0] = 0x004;
			noiseWavelengthLookup[0x1] = 0x008;
			noiseWavelengthLookup[0x2] = 0x010;
			noiseWavelengthLookup[0x3] = 0x020;
			noiseWavelengthLookup[0x4] = 0x040;
			noiseWavelengthLookup[0x5] = 0x060;
			noiseWavelengthLookup[0x6] = 0x080;
			noiseWavelengthLookup[0x7] = 0x0A0;
			noiseWavelengthLookup[0x8] = 0x0CA;
			noiseWavelengthLookup[0x9] = 0x0FE;
			noiseWavelengthLookup[0xA] = 0x17C;
			noiseWavelengthLookup[0xB] = 0x1FC;
			noiseWavelengthLookup[0xC] = 0x2FA;
			noiseWavelengthLookup[0xD] = 0x3F8;
			noiseWavelengthLookup[0xE] = 0x7F2;
			noiseWavelengthLookup[0xF] = 0xFE4;
			
		}
	
		public	function initDACtables():void
		{
			square_table = new Vector.<int>(32*16);
			tnd_table = new Vector.<int>(204*16);
			var value:Number;
			
			var ival:int;
			var max_sqr:int = 0;
			var max_tnd:int = 0;
			var i:int;
			for (i = 0 ; i < (32*16) ; i++)
			{
				value = 95.52 / (8128.0 / (Number(i)/16.0) + 100.0);
				value *= 0.98411;
				value *= 50000.0;
				ival = int(value);
				
				square_table[i] = ival;
				if (ival > max_sqr)
				{
					max_sqr = ival;
				}
			}
			
			for(i = 0 ; i < (204*16) ; i++)
			{
				value = 163.67 / (24329.0 / (Number(i)/16.0) + 100.0);
				value *= 0.98411;
				value *= 50000.0;
				ival = int(value);
				
				tnd_table [i] = ival;
				if (ival > max_tnd)
				{
					max_tnd = ival;
				}
			}
			
			this.dacRange = max_sqr+max_tnd;
			this.dcValue = dacRange/2;
		}
	
		public	function destroy():void
		{
			nes = null;
			cpuMem = null;
	
			if (square1 != null)
				square1.destroy();
			if (square2 != null)
				square2.destroy();
			if (triangle != null)
				triangle.destroy();
			if (noise != null)
				noise.destroy();
			if (dmc != null)
				dmc.destroy();
	
			square1 = null;
			square2 = null;
			triangle = null;;
			noise = null;
			dmc = null;
	
			mixer = null;
			line = null;
		}
	}
}