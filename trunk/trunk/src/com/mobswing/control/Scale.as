package com.mobswing.control
{
	public class Scale
	{
		private static var brightenShift		:int;
		private static var brightenShiftMask	:int;
		private static var brightenCutoffMask	:int;

		private static var darkenShift			:int;
		private static var darkenShiftMask		:int;
		private static var si:int, di:int, di2:int, val:int, x:int, y:int;
		
		public function Scale()
		{
		}

		public	static function setFilterParams(darkenDepth:int, brightenDepth:int):void
		{
			switch (darkenDepth)
			{
			case 0:
				darkenShift     = 0;
				darkenShiftMask = 0x00000000;
				break;
			case 1:
				darkenShift     = 4;
				darkenShiftMask = 0x000F0F0F;
				break;
			case 2:
				darkenShift     = 3;
				darkenShiftMask = 0x001F1F1F;
				break;
			case 3:
				darkenShift     = 2;
				darkenShiftMask = 0x003F3F3F;
				break;
			default:
				darkenShift     = 1;
				darkenShiftMask = 0x007F7F7F;
				break;
			}
			
			switch (brightenDepth)
			{
			case 0:
				brightenShift      = 0;
				brightenShiftMask  = 0x00000000;
				brightenCutoffMask = 0x00000000;
				break;
			case 1:
				brightenShift      = 4;
				brightenShiftMask  = 0x000F0F0F;
				brightenCutoffMask = 0x003F3F3F;
				break;
			case 2:
				brightenShift      = 3;
				brightenShiftMask  = 0x001F1F1F;
				brightenCutoffMask = 0x003F3F3F;
				break;
			case 3:
				brightenShift      = 2;
				brightenShiftMask  = 0x003F3F3F;
				brightenCutoffMask = 0x007F7F7F;
				break;
			default:
				brightenShift      = 1;
				brightenShiftMask  = 0x007F7F7F;
				brightenCutoffMask = 0x007F7F7F;
				break;
			}
		}

		public	static function doScanlineScaling(src:Vector.<uint>, dst:Vector.<uint>, changed:Vector.<Boolean>):void
		{
			var di:int = 0;
			var di2:int = 512;
			var val:int, max:int;
			
			for (var y:int = 0 ; y < 240 ; y++)
			{
				if (changed[y])
				{
					max = (y+1)<<8;
					for (var si:int = (y<<8) ; si < max ; si++)
					{
						val = src[si] & 0xFFFFFF;
						
						dst[di] = uint(uint(val) | 0xFF000000);
						dst[++di] = uint(uint(val) | 0xFF000000);

						val -= ((val>>2)&0x003F3F3F);
						
						dst[di2] = uint(uint(val) | 0xFF000000);
						dst[++di2] = uint(uint(val) | 0xFF000000);
						
						di ++;
						di2++;
					}
				}
				else
				{
					di += 512;
					di2+= 512;
				}
				
				di +=512;
				di2+=512;
			}
		}

		public	static function doRasterScaling(src:Vector.<uint>, dst:Vector.<uint>, changed:Vector.<Boolean>):void
		{
			var di:int = 0;
			var di2:int = 512;
			
			var max:int;
			var col1:int, col2:int, col3:int;
			var r:int, g:int, b:int;
			var flag:int = 0;
			
			for (var y:int = 0 ; y < 240 ; y++)
			{
				if (changed[y])
				{
					max = (y+1)<<8;
					for (var si:int = (y<<8) ; si < max ; si++)
					{
						
						col1 = src[si] & 0xFFFFFF;
						
						dst[di] = src[si];
						dst[++di] = src[si];
						
						dst[di2] = src[si];
						dst[++di2] = src[si];
						
						col2 = col1 - ((col1>>darkenShift)&darkenShiftMask);
						
						col3 = col1 + 
							(
								(
									(
										(0x00FFFFFF-col1)&brightenCutoffMask
									)>>brightenShift
								)&brightenShiftMask
							);
						
						dst[di+(512&flag)] = uint(uint(col2) | 0xFF000000);
						dst[di+(512&flag)-1] = uint(uint(col2) | 0xFF000000);
						dst[di+512&(512-flag)] = uint(uint(col3) | 0xFF000000);
						flag = 512-flag;
						
						di ++;
						di2++;
						
					}
				}
				else
				{
					di += 512;
					di2+= 512;
				}
				
				di +=512;
				di2+=512;
			}
		}

		public	static function doNormalScaling(src:Vector.<uint>, dst:Vector.<uint>, changed:Vector.<Boolean>):void
		{
			var di:int = 0;
			var di2:int = 512;
			var val:int, max:int;
			
			for (var y:int = 0 ; y < 240 ; y++)
			{
				if (changed[y])
				{
					max = (y+1)<<8;
					for (var si:int = (y<<8) ; si < max ; si++)
					{
						
						val = src[si] & 0xFFFFFF;
						
						dst[di++] = src[si];
						dst[di++] = src[si];
						
						dst[di2++] = src[si];
						dst[di2++] = src[si];
					}
				}
				else
				{
					di += 512;
					di2+= 512;
				}
				
				di +=512;
				di2+=512;
			}
		}
	}
}