package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	import com.mobswing.control.FilePreloader;
	
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	public class ROM
	{
		public static const VERTICAL_MIRRORING		:int = 0;
		public static const HORIZONTAL_MIRRORING	:int = 1;
		public static const FOURSCREEN_MIRRORING	:int = 2;
		public static const SINGLESCREEN_MIRRORING	:int = 3;
		public static const SINGLESCREEN_MIRRORING2	:int = 4;
		public static const SINGLESCREEN_MIRRORING3	:int = 5;
		public static const SINGLESCREEN_MIRRORING4	:int = 6;
		public static const CHRROM_MIRRORING		:int = 7;
		
		private var failedSaveFile	:Boolean = false;
		private var saveRamUpToDate	:Boolean = true;
		
		private	var header	:Vector.<int>;
		private	var rom		:Vector.<Vector.<int>>;
		private	var vrom	:Vector.<Vector.<int>>;
		private	var saveRam	:Vector.<int>;
		private	var vromTile:Vector.<Vector.<Tile>>;
		
		private var nes			:Nes;
		private var romCount	:int;
		private var vromCount	:int;
		private	var mirroring	:int;
		public	var batteryRam	:Boolean;
		private	var trainer		:Boolean;
		private	var fourScreen	:Boolean;
		private	var mapperType	:int;
		private var fileName	:String;
//		private	var raFile		:RandomAccessFile;
		private	var enableSave	:Boolean = true;
		private var valid		:Boolean;
		
		protected var crc32:Number = 0;
		
		public	static const mapperName:Vector.<String> = Vector.<String>([
			"NROM",
			"Nintendo MMC1",
			"UxROM",
			"CNROM",
			"Nintendo MMC3",
			"Nintendo MMC5",
			"FFE F4xxx",
			"AxROM",
			"FFE F3xxx",
			"Nintendo MMC2",
			"Nintendo MMC4",
			"Color Dreams",
			"FFE F6xxx",
			"CPROM",
			"Unknown Mapper",
			"iNES Mapper #015",
			"Bandai",
			"FFE F8xxx",
			"Jaleco SS8806",
			"Namcot 106",
			"(Hardware) Famicom Disk System",
			"Konami VRC4a, VRC4c",
			"Konami VRC2a",
			"Konami VRC2b, VRC4e, VRC4f",
			"Konami VRC6a",
			"Konami VRC4b, VRC4d",
			"Konami VRC6b",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Irem G-101",
			"Taito TC0190, TC0350",
			"BxROM, NINA-001",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Caltron 6-in-1",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Rumblestation 15-in-1",
			"Nintendo MMC3 Multicart (Super Spike V'Ball + Nintendo World Cup)",
			"iNES Mapper #048",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Tengen RAMBO-1",
			"Irem H-3001",
			"GxROM",
			"Sunsoft 3",
			"Sunsoft 4",
			"Sunsoft FME-7",
			"iNES Mapper #070",
			"Camerica",
			"iNES Mapper #072",
			"Konami VRC3",
			"Unknown Mapper",
			"Konami VRC1",
			"iNES Mapper #076 (Digital Devil Monogatari - Megami Tensei)",
			"iNES Mapper #077 (Napoleon Senki)",
			"Irem 74HC161/32",
			"American Game Cartridges",
			"iNES Mapper #080",
			"Unknown Mapper",
			"iNES Mapper #082",
			"Unknown Mapper",
			"Unknown Mapper",
			"Konami VRC7a, VRC7b",
			"iNES Mapper #086 (Moero!! Pro Yakyuu)",
			"iNES Mapper #087",
			"iNES Mapper #088",
			"iNES Mapper #087 (Mito Koumon)",
			"Unknown Mapper",
			"Unknown Mapper",
			"iNES Mapper #092",
			"iNES Mapper #093 (Fantasy Zone)",
			"iNES Mapper #094 (Senjou no Ookami)",
			"iNES Mapper #095 (Dragon Buster) [MMC3 Derived]",
			"(Hardware) Oeka Kids Tablet",
			"iNES Mapper #097 (Kaiketsu Yanchamaru)",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"NES-EVENT [MMC1 Derived]",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"iNES Mapper #113",
			"Unknown Mapper",
			"iNES Mapper #115 (Yuu Yuu Hakusho Final) [MMC3 Derived]",
			"Unknown Mapper",
			"Unknown Mapper",
			"iNES Mapper #118 [MMC3 Derived]",
			"TQROM",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"iNES Mapper #140 (Bio Senshi Dan)",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"iNES Mapper #152",
			"Unknown Mapper",
			"iNES Mapper #152 (Devil Man)",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Bandai (Alternate of #016)",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"(Hardware) Crazy Climber Controller",
			"Unknown Mapper",
			"iNES Mapper #182",
			"Unknown Mapper",
			"iNES Mapper #184",
			"iNES Mapper #185",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"iNES Mapper #185 (Fudou Myouou Den)",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Active Enterprises",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Camerica (Quattro series)",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper",
			"Unknown Mapper"
		]);
		public	static const supportedMapper:Vector.<Boolean> = Vector.<Boolean>([
			true	,true	,true	,true	,true		,false	,false	,true	,false	,true	,
			true	,true	,false	,false	,false		,true	,false	,false	,true	,false	,
			false	,true	,true	,true	,false		,false	,false	,false	,false	,false	,
			false	,false	,true	,true	,true		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,true	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,true		,false	,true	,false	,true	,false	,
			false	,true	,true	,false	,false		,true	,false	,false	,true	,true	,
			false	,false	,false	,false	,false		,false	,false	,true	,false	,false	,
			false	,false	,false	,false	,true		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,true	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			true	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,true	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,true	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false		,false	,false	,false	,false	,false	,
			false	,false	,false	,false	,false
		]);

		public function ROM(nes:Nes)
		{
			this.nes = nes;
			this.valid = false;
		}
		
		public	function load(filename:String):void
		{
			this.fileName = filename;
			var i:int, j:int;
			var ba:ByteArray = FilePreloader.getInstance().getFile('rom') as ByteArray;
			var b:Vector.<int> = new Vector.<int>(ba.length);
			
			ba.position = 0;
			for (i = 0 ; i < ba.length ; i++)
			{
				b[i] = ba.readByte() & 255;
			}
			
			if (b == null || b.length == 0)
			{
				this.nes.getGui().showErrorMessage("Unable to load ROM file.");
				this.valid = false;				
				return;
			}
			
			this.header = new Vector.<int>(16);
			for (i = 0 ; i < 16 ; i++)
			{
				this.header[i] = b[i];
			}
			
			var fcode:String = String.fromCharCode(b[0]) + String.fromCharCode(b[1]) + String.fromCharCode(b[2]) + String.fromCharCode(b[3]);
			if (fcode != 'NES' + String.fromCharCode(0x1A))
			{
				trace("Header is incorrect.");
				this.valid = false;
				return;
			}
			
			this.romCount	= this.header[4];
			this.vromCount	= this.header[5] * 2;
			this.mirroring	= ((this.header[6]&1)!=0?1:0);
			this.batteryRam	= (this.header[6]&2)!=0;
			this.trainer	= (this.header[6]&4)!=0;
			this.fourScreen	= (this.header[6]&8)!=0;
			this.mapperType	= (this.header[6]>>4)|(this.header[7]&0xF0);
			
			if (this.batteryRam)
				loadBatteryRam();
			
			var foundError:Boolean = false;
			for (i = 8 ; i < 16 ; i++)
			{
				if (this.header[i] != 0)
				{
					foundError = true;
					break;
				}
			}
			if (foundError)
				this.mapperType &= 0xF;
				
			this.rom		= new Vector.<Vector.<int>>(this.romCount);// short[romCount][16384];
			for (i = 0 ; i < this.romCount ; i++)
				this.rom[i] = new Vector.<int>(16384);
			this.vrom		= new Vector.<Vector.<int>>(this.vromCount);// short[vromCount][4096];
			for (i = 0 ; i < this.vromCount ; i++)
				this.vrom[i] = new Vector.<int>(4096);
			this.vromTile	= new Vector.<Vector.<Tile>>(this.vromCount);//Tile[vromCount][256];
			for (i = 0 ; i < this.vromCount ; i++)
				this.vromTile[i] = new Vector.<Tile>(256);

			var offset:int = 16;
			for (i = 0 ; i < this.romCount ; i++)
			{
				for (j = 0 ; j < 16384 ; j++)
				{
					if (offset+j >= b.length)
						break;
					this.rom[i][j] = b[offset+j];
				}
				offset += 16384;
			}
			
			for (i = 0 ; i < this.vromCount ; i++)
			{
				for (j = 0 ; j < 4096 ; j++)
				{
					if (offset+j >= b.length)
						break;
					this.vrom[i][j] = b[offset+j];
				}
				offset += 4096;
			}
			
			for (i = 0 ; i < this.vromCount ; i++)
			{
				for (j = 0 ; j < 256 ; j++)
				{
					this.vromTile[i][j] = new Tile();
				}
			}
			
			var tileIndex:int;
			var leftOver:int;
			for (i = 0 ; i < this.vromCount ; i++)
			{
				for (j = 0 ; j < 4096 ; j++)
				{
					tileIndex = j >> 4;
					leftOver = j % 16;
					if (leftOver < 8)
					{
						this.vromTile[i][tileIndex].setScanline(leftOver, this.vrom[i][j], this.vrom[i][j+8]);
					}
					else
					{
						this.vromTile[i][tileIndex].setScanline(leftOver-8, this.vrom[i][j-8], this.vrom[i][j]);
					}
				}
			}
			
			//var tempArray:ByteArray = new ByteArray(this.rom.length + this.vrom.length);
			//this.crc32 = Crc32.encode(tempArray);
			
			this.valid = true;
		}

		public	function isValid():Boolean
		{
			return this.valid;
		}

		public	function getRomBankCount():int
		{
			return this.romCount;
		}
		
		public	function getVromBankCount():int
		{
			return this.vromCount;
		}
		
		public	function getHeader():Vector.<int>
		{
			return this.header;
		}
		
		public	function getRomBank(bank:int):Vector.<int>
		{
			return this.rom[bank];
		}
		
		public	function getVromBank(bank:int):Vector.<int>
		{
			return this.vrom[bank];
		}
		
		public	function getVromBankTiles(bank:int):Vector.<Tile>
		{
			return this.vromTile[bank];
		}
		
		public	function getMirroringType():int
		{
			
			if (this.fourScreen)
				return FOURSCREEN_MIRRORING;
			
			if (this.mirroring == 0)
				return HORIZONTAL_MIRRORING;
			
			return VERTICAL_MIRRORING;
		}
		
		public	function getMapperType():int
		{
			return this.mapperType;
		}
		
		public	function getMapperName():String
		{
		    if (this.mapperType>=0 && this.mapperType<mapperName.length)
				return mapperName[this.mapperType];
			return "Unknown Mapper, " + this.mapperType.toString();
		}
		
		public	function hasBatteryRam():Boolean
		{
			return this.batteryRam;
		}
		
		public	function hasTrainer():Boolean
		{
			return this.trainer;
		}
		
		public	function getFileName():String
		{
			var i:int = this.fileName.lastIndexOf('/');
			i = (i < 0) ? 0:i;
			return this.fileName.substr(i);
		}
		
		public	function mapperSupported():Boolean
		{
			if (this.mapperType<supportedMapper.length && this.mapperType>=0)
				return supportedMapper[this.mapperType];
			return false;
		}
		
		public	function createMapper():IMemoryMapper
		{
			
	        if (mapperSupported())
	        {
	            switch (this.mapperType)
	            {
	                case 0: {
	                    return new MapperDefault();
	                }
	                case 1: {
	                    return new Mapper001();
	                }
	                case 2: {
	                    return new Mapper002();
	                }
	                case 3: {
	                    return new Mapper003();
	                }
	                case 4: {
	                    return new Mapper004();
	                }
	                case 7: {
	                    return new Mapper007();
	                }
	                case 9: {
	                    return new Mapper009();
	                }
	                case 10: {
	                    return new Mapper010();
	                }
	                case 11: {
	                    return new Mapper011();
	                }
	                case 15: {
	                    return new Mapper015();
	                }
	                case 18: {
	                    return new Mapper018();
	                }
	                case 21: {
	                    return new Mapper021();
	                }
	                case 22: {
	                    return new Mapper022();
	                }
	                case 23:{
	                    return new Mapper023();
	                }
	                case 32: {
	                    return new Mapper032();
	                }
	                case 33: {
	                    return new Mapper033();
	                }
	                case 34: {
	                    return new Mapper034();
	                }
	                case 48:{
	                    return new Mapper048();
	                }
	                case 64: {
	                    return new Mapper064();
	                }
	                case 66: {
	                    return new Mapper066();
	                }
	                case 68: {
	                    return new Mapper068();
	                }
	                case 71: {
	                    return new Mapper071();
	                }
	                case 72: {
	                    return new Mapper072();
	                }
	                case 75: {
	                    return new Mapper075();
	                }
	                case 78: {
	                    return new Mapper078();
	                }
	                case 79: {
	                    return new Mapper079();
	                }
	                case 87: {
	                    return new Mapper087();
	                }
	                case 94: {
	                    return new Mapper094();
	                }
	                case 105: {
	                    return new Mapper105();
	                }
	                case 140: {
	                    return new Mapper140();
	                }
	                case 182: {
	                    return new Mapper182();
	                }
	                case 232: {
	                    return new Mapper232();
	                }
	            }
	        }
			// If the mapper wasn't supported, create the standard one:
			nes.gui.showErrorMessage("Warning: Mapper not supported yet.");
			return new MapperDefault();
		}
		
		public	function setSaveState(enableSave:Boolean):void
		{
			if (enableSave && !this.batteryRam)
				loadBatteryRam();
		}
		
		public	function getBatteryRam():Vector.<int>
		{
			return this.saveRam;
		}
		
		private	function loadBatteryRam():void
		{
			if	(this.batteryRam)
			{
				try{
					this.saveRam = new Vector.<int>(0x2000);
					this.saveRamUpToDate = true;
					
					// Get hex-encoded memory string from user:
					//var encodedData:String = JOptionPane.showInputDialog("Returning players insert Save Code here.");	//*******
					var so:SharedObject = SharedObject.getLocal('as3nes');
					var encodedData:String = so.data[getFileName()];
					if (encodedData==null)
						return;
					
					// Remove all garbage from encodedData:
					encodedData = encodedData.replace(/[^\\p{XDigit}]/g, "");
					if (encodedData.length != this.saveRam.length*2)
						return;
					
					// Convert hex-encoded memory string to bytes:
					for (var i:int = 0 ; i < this.saveRam.length ; i++)
					{
						var hexByte:String = encodedData.substring(i*2, i*2+2);
						this.saveRam[i] = parseInt(hexByte, 16);
					}
					
					//System.out.println("Battery RAM loaded.");
					if(this.nes.getMemoryMapper() != null)
						nes.getMemoryMapper().loadBatteryRam();
				}
				catch(e:Error)
				{
					//System.out.println("Unable to get battery RAM from user.");
					this.failedSaveFile = true;
				}
			}
		}
		
		public	function writeBatteryRam(address:int, value:int):void
		{
			if ((!this.failedSaveFile) && (!this.batteryRam) && this.enableSave)
				loadBatteryRam();
			
			//System.out.println("Trying to write to battery RAM. batteryRam="+batteryRam+" enableSave="+enableSave);
			if (this.batteryRam && this.enableSave && (!this.failedSaveFile))
			{
				this.saveRam[address-0x6000] = value;
				this.saveRamUpToDate = false;
			}
			
		}
	
		public	function closeRom():void
		{
			if (this.batteryRam && (!this.saveRamUpToDate))
			{
				try{
					// Convert bytes to hex-encoded memory string:
					var sb:Array = new Array();
					for (var i:int = 0 ; i < this.saveRam.length ; i++)
					{
						var hexByte:String = (saveRam[i] & 0xFF).toString(16);
						if ((i%38 == 0) && (i != 0))
							sb.push(" ");
						sb.push(hexByte);
					}
					var encodedData:String = sb.join('');
					
					// Send hex-encoded memory string to user:
					//JOptionPane.showInputDialog("Save Code for Resuming Game.", encodedData);
					var so:SharedObject = SharedObject.getLocal('as3nes');
					so.data[getFileName()] = encodedData;
					so.flush();
					
					this.saveRamUpToDate = true;
					//System.out.println("Battery RAM sent to user.");
					
				}
				catch(e:Error)
				{
					trace("Trouble sending battery RAM to user.");
					//e.printStackTrace();
				}
			}
		}
		
		public	function destroy():void
		{
			closeRom();
			this.nes = null;
		}
	}
}