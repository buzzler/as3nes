package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	public class Tile
	{
		public	var pix:Vector.<int>;
		private	var fbIndex:int;
		private var tIndex:int;
		private var x:int, y:int;
		private	var w:int, h:int;
		private	var incX:int, incY:int;
		private	var	palIndex:int;;
		private	var tpri:int;
		private	var c:int;
		public	var initialized:Boolean = false;
		public	var opaque:Vector.<Boolean> = new Vector.<Boolean>(8);
		
		public function Tile()
		{
			pix = new Vector.<int>(64);
		}

		public	function setScanline(sline:int, b1:int, b2:int):void
		{
			initialized = true;
			tIndex = sline<<3;
			for (x = 0 ; x < 8 ; x++)
			{
				pix[tIndex+x] = ((b1>>(7-x))&1) + (((b2>>(7-x))&1)<<1);
				if (pix[tIndex+x] == 0)
					opaque[sline] = false;
			}
		}
		
		public	function render(srcx1:int, srcy1:int, srcx2:int, srcy2:int, dx:int, dy:int, fBuffer:Vector.<uint>, palAdd:int, palette:Vector.<int>, flipHorizontal:Boolean, flipVertical:Boolean, pri:int, priTable:Vector.<int>):void
		{
			if (dx<-7 || dx>=Globals.WIDTH || dy<-7 || dy>=Globals.HEIGHT)
			{
				return;
			}
		
			w=srcx2-srcx1;
			h=srcy2-srcy1;
			
			if (dx<0)
			{
				srcx1-=dx;
			}
			if (dx+srcx2>=Globals.WIDTH)
			{
				srcx2=Globals.WIDTH-dx;
			}
			
			if (dy<0)
			{
				srcy1-=dy;
			}
			if (dy+srcy2>=Globals.HEIGHT)
			{
				srcy2=Globals.HEIGHT-dy;
			}
			
			if (!flipHorizontal && !flipVertical)
			{
				fbIndex = (dy<<8)+dx;
				tIndex = 0;
				for (y=0;y<8;y++)
				{
					for (x=0;x<8;x++)
					{
						if (x>=srcx1 && x<srcx2 && y>=srcy1 && y<srcy2)
						{
							palIndex = pix[tIndex];
							tpri = priTable[fbIndex];
							if (palIndex!=0 && pri<=(tpri&0xFF))
							{
								//fBuffer[fbIndex] = uint(uint(palette[palIndex+palAdd]) | 0xFF000000);
								fBuffer[fbIndex] = palette[palIndex+palAdd];
								tpri = (tpri&0xF00)|pri;
								priTable[fbIndex] =tpri;
							}
						}
						fbIndex++;
						tIndex++;
					}
					fbIndex-=8;
					fbIndex+=256;
				}
			}
			else if (flipHorizontal && !flipVertical)
			{
				fbIndex = (dy<<8)+dx;
				tIndex = 7;
				for (y = 0 ; y < 8 ; y++)
				{
					for (x = 0 ; x < 8 ; x++)
					{
						if (x>=srcx1 && x<srcx2 && y>=srcy1 && y<srcy2)
						{
							palIndex = pix[tIndex];
							tpri = priTable[fbIndex];
							if (palIndex!=0 && pri<=(tpri&0xFF))
							{
								//fBuffer[fbIndex] = uint(uint(palette[palIndex+palAdd]) | 0xFF000000);
								fBuffer[fbIndex] = palette[palIndex+palAdd];
								tpri = (tpri&0xF00)|pri;
								priTable[fbIndex] =tpri;
							}
						}
						fbIndex++;
						tIndex--;
					}
					fbIndex-=8;
					fbIndex+=256;
					tIndex+=16;
				}
			}
			else if (flipVertical && !flipHorizontal)
			{
				fbIndex = (dy<<8)+dx;
				tIndex = 56;
				for (y = 0 ; y < 8 ; y++)
				{
					for (x = 0 ; x < 8 ; x++)
					{
						if (x>=srcx1 && x<srcx2 && y>=srcy1 && y<srcy2)
						{
							palIndex = pix[tIndex];
							tpri = priTable[fbIndex];
							if (palIndex!=0 && pri<=(tpri&0xFF))
							{
								//fBuffer[fbIndex] = uint(uint(palette[palIndex+palAdd]) | 0xFF000000);
								fBuffer[fbIndex] = palette[palIndex+palAdd];
								tpri = (tpri&0xF00)|pri;
								priTable[fbIndex] =tpri;
							}
						}
						fbIndex++;
						tIndex++;
					}
					fbIndex-=8;
					fbIndex+=256;
					tIndex-=16;
				}
			}
			else
			{
				fbIndex = (dy<<8)+dx;
				tIndex = 63;
				for (y = 0 ; y < 8 ; y++)
				{
					for (x = 0 ; x < 8 ; x++)
					{
						if (x>=srcx1 && x<srcx2 && y>=srcy1 && y<srcy2)
						{
							palIndex = pix[tIndex];
							tpri = priTable[fbIndex];
							if(palIndex!=0 && pri<=(tpri&0xFF))
							{
								//fBuffer[fbIndex] = uint(uint(palette[palIndex+palAdd]) | 0xFF000000);
								fBuffer[fbIndex] = palette[palIndex+palAdd];
								tpri = (tpri&0xF00)|pri;
								priTable[fbIndex] =tpri;
							}
						}
						fbIndex++;
						tIndex--;
					}
					fbIndex-=8;
					fbIndex+=256;
				}
			}
		}
		
		public	function stateSave(buf:ByteBuffer):void
		{
			var i:int;
			buf.putBoolean(initialized);
			for (i = 0 ; i < 8 ; i++)
			{
				buf.putBoolean(opaque[i]);
			}
			for (i = 0 ; i < 64 ; i++)
			{
				buf.putByte(pix[i] & 255);
			}
		}
		
		public	function stateLoad(buf:ByteBuffer):void
		{
			initialized = buf.readBoolean();
			var i:int;
			for (i = 0 ; i < 8 ; i++)
			{
				opaque[i] = buf.readBoolean();
			}
			for (i = 0 ; i < 64 ; i++)
			{
				pix[i] = buf.readByte();
			}
		}
	}
}