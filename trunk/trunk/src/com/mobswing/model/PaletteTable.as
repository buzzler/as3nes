package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	import com.mobswing.control.FilePreloader;
	
	public class PaletteTable
	{
		public	static var curTable:Vector.<int>  = new Vector.<int>(64);
		public	static var origTable:Vector.<int> = new Vector.<int>(64);
		public	static var emphTable:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(8);// int[8][64];
		
		private var currentEmph:int = -1;
		private var currentHue:int, currentSaturation:int, currentLightness:int, currentContrast:int;
		
		public function PaletteTable()
		{
			if (emphTable[0] == null)
			{
				for (var i:int = 0 ; i < 8 ; i++)
				{
					emphTable[i] = new Vector.<int>(64);
				}
			}
		}

		private function loadPalette(fStr:String):Boolean
		{
			var r:int, g:int, b:int;

			try
			{
				var palIndex:int = 0;
				while (true)
				{
					var i:int = fStr.indexOf('#');
					if ((i < 0)||(fStr.length < 7))
						break;

					fStr = fStr.substr(i);
					r = parseInt(fStr.substr(1,2), 16);
					g = parseInt(fStr.substr(3,2), 16);
					b = parseInt(fStr.substr(5,2), 16);
					
					origTable[palIndex] = r | (g << 8) | (b << 16);
					palIndex++;
					fStr = fStr.substr(7);
				}
				
				setEmphasis(0);
				makeTables();
				updatePaletteAll();
			}
			catch(e:Error)
			{
				trace("PaletteTable: Internal Palette Loaded.");
				loadDefaultPalette();
				
				return false;
			}
			return true;
		}
		
		public	function loadNTSCPalette():Boolean
		{
			var loader:FilePreloader = FilePreloader.getInstance();
			var str:String = loader.getFile('ntsc') as String;
			return loadPalette(str);
		}
		
		public	function loadPALPalette():Boolean
		{
			var loader:FilePreloader = FilePreloader.getInstance();
			var str:String = loader.getFile('pal') as String;
			return loadPalette(str);
		}

		public function makeTables():void
		{
			var r:int, b:int, g:int, col:int;

			for (var emph:int = 0 ; emph < 8 ; emph++)
			{
				var rFactor:Number = 1.0, gFactor:Number = 1.0, bFactor:Number = 1.0;
				
				if ((emph&1) != 0)
				{
					rFactor = 0.75;
					bFactor = 0.75;
				}
				if ((emph&2) != 0)
				{
					rFactor = 0.75;
					gFactor = 0.75;
				}
				if ((emph&4) != 0)
				{
					gFactor = 0.75;
					bFactor = 0.75;
				}

				for (var i:int = 0 ; i < 64 ; i++)
				{
					col = origTable[i];
					r = (int)(getRed(col) * rFactor);
					g = (int)(getGreen(col) * gFactor);
					b = (int)(getBlue(col) * bFactor);
					emphTable[emph][i] = getRgb(r,g,b);
				}
			}
		}
		
		public	function setEmphasis(emph:int):void
		{
			if (emph != currentEmph)
			{
				currentEmph = emph;
				for (var i:int = 0 ; i < 64 ; i++)
				{
					curTable[i] = emphTable[emph][i];
				}
				updatePaletteAll();
			}
		}

		public	function getEntry(yiq:int):int
		{
			return curTable[yiq];
		}

		private	function RGBtoHSB(r:int, g:int, b:int, hsbvals:Vector.<Number>):Vector.<Number>
		{
			var hue:Number, saturation:Number, brightness:Number;
			
			if (hsbvals == null)
			    hsbvals = new Vector.<Number>(3);
			var cmax:int = (r > g) ? r : g;
			if (b > cmax)
				cmax = b;
			var cmin:int = (r < g) ? r : g;
			if (b < cmin)
				cmin = b;
		
			brightness = Number(cmax) / 255.0;
			if (cmax != 0)
			{
			    saturation = Number((cmax - cmin) / cmax);
			}
			else
			{
			    saturation = 0.0;
			}
			if (saturation == 0)
			{
			    hue = 0.0;
			}
			else
			{
			    var redc:Number = Number(cmax - r) / Number(cmax - cmin);
			    var greenc:Number = Number(cmax - g) / Number(cmax - cmin);
			    var bluec:Number = Number(cmax - b) / Number(cmax - cmin);
			    if (r == cmax)
					hue = bluec - greenc;
			    else if (g == cmax)
			        hue = 2.0 + redc - bluec;
				else
					hue = 4.0 + greenc - redc;
			    hue = hue / 6.0;
			    if (hue < 0)
					hue = hue + 1.0;
			}
			hsbvals[0] = hue;
			hsbvals[1] = saturation;
			hsbvals[2] = brightness;
			return hsbvals;
	    }

	    public	function HSBtoRGB(hue:Number, saturation:Number, brightness:Number):int
	    {
			var r:int = 0, g:int = 0, b:int = 0;
		    if (saturation == 0)
		    {
			    r = g = b = int(brightness * 255.0 + 0.5);
			}
			else
			{
			    var h:Number = (hue - Math.floor(hue)) * 6.0;
			    var f:Number = h - Math.floor(h);
			    var p:Number = brightness * (1.0 - saturation);
			    var q:Number = brightness * (1.0 - saturation * f);
			    var t:Number = brightness * (1.0 - (saturation * (1.0 - f)));
			    switch (int(h))
			    {
			    case 0:
					r = int(brightness * 255.0 + 0.5);
					g = int(t * 255.0 + 0.5);
					b = int(p * 255.0 + 0.5);
					break;
			    case 1:
					r = int(q * 255.0 + 0.5);
					g = int(brightness * 255.0 + 0.5);
					b = int(p * 255.0 + 0.5);
					break;
			    case 2:
					r = int(p * 255.0 + 0.5);
					g = int(brightness * 255.0 + 0.5);
					b = int(t * 255.0 + 0.5);
					break;
			    case 3:
					r = int(p * 255.0 + 0.5);
					g = int(q * 255.0 + 0.5);
					b = int(brightness * 255.0 + 0.5);
					break;
			    case 4:
					r = int(t * 255.0 + 0.5);
					g = int(p * 255.0 + 0.5);
					b = int(brightness * 255.0 + 0.5);
					break;
			    case 5:
					r = int(brightness * 255.0 + 0.5);
					g = int(p * 255.0 + 0.5);
					b = int(q * 255.0 + 0.5);
					break;
			    }
			}
			return 0xff000000 | (r << 16) | (g << 8) | (b << 0);
	    }

		public	function RGBtoHSL(r:int, g:int, b:int):int
		{
			var hsbvals:Vector.<Number> = new Vector.<Number>(3);
			hsbvals = RGBtoHSB(b,g,r,hsbvals);
			hsbvals[0] -= Math.floor(hsbvals[0]);
			
			var ret:int = 0;
			ret |= ((int(hsbvals[0]*255))<<16);
			ret |= ((int(hsbvals[1]*255))<< 8);
			ret |= ((int(hsbvals[2]*255))    );
			return ret;
		}
		
		public	function RGBtoHSLOne(rgb:int):int
		{
			return RGBtoHSL((rgb>>16)&0xFF,(rgb>>8)&0xFF,(rgb)&0xFF);
		}
		
		public	function HSLtoRGB(h:int, s:int, l:int):int
		{
			return HSBtoRGB(h/255.0,s/255.0,l/255.0);
		}
		
		public	function HSLtoRGBOne(hsl:int):int
		{
			var h:Number,s:Number,l:Number;
			h = Number(((hsl>>16)&0xFF)/255);
			s = Number(((hsl>> 8)&0xFF)/255);
			l = Number(((hsl    )&0xFF)/255);
			return HSBtoRGB(h,s,l);
			
		}
		
		public	function getHue(hsl:int):int
		{
			return (hsl>>16)&0xFF;
		}

		public	function getSaturation(hsl:int):int
		{
			return (hsl>>8)&0xFF;
		}

		public	function getLightness(hsl:int):int
		{
			return hsl&0xFF;
		}
		
		public	function getRed(rgb:int):int
		{
			return (rgb>>16)&0xFF;
		}
		
		public	function getGreen(rgb:int):int
		{
			return (rgb>>8)&0xFF;
		}
		
		public	function getBlue(rgb:int):int
		{
			return rgb&0xFF;
		}
		
		public	function getRgb(r:int, g:int, b:int):int
		{
			return ((r<<16)|(g<<8)|(b));
		}
		
		
		public	function updatePaletteAll():void
		{
			updatePalette(currentHue, currentSaturation, currentLightness, currentContrast);
		}

		public	function updatePalette(hueAdd:int, saturationAdd:int, lightnessAdd:int, contrastAdd:int):void
		{
			var hsl:int, rgb:int;
			var h:int, s:int, l:int;
			var r:int, g:int, b:int;

			if (contrastAdd > 0)
				contrastAdd *= 4;
			for (var i:int = 0 ; i < 64 ; i++)
			{
				hsl = RGBtoHSLOne(emphTable[currentEmph][i]);
				h = getHue(hsl)+hueAdd;
				s = int(getSaturation(hsl)*(1.0+saturationAdd/256));
				l = getLightness(hsl);
				
				if (h<0)h+=255;
				if (s<0)s=0;
				if (l<0)l=0;
				
				if(h>255)h-=255;
				if(s>255)s=255;
				if(l>255)l=255;
				
				rgb = HSLtoRGB(h,s,l);
				
				r = getRed(rgb);
				g = getGreen(rgb);
				b = getBlue(rgb);
				
				r = 128 + lightnessAdd + int((r-128)*(1.0+contrastAdd/256));
				g = 128 + lightnessAdd + int((g-128)*(1.0+contrastAdd/256));
				b = 128 + lightnessAdd + int((b-128)*(1.0+contrastAdd/256));
				
				if (r<0)r=0;
				if (g<0)g=0;
				if (b<0)b=0;
				
				if (r>255)r=255;
				if (g>255)g=255;
				if (b>255)b=255;
				
				rgb = getRgb(r,g,b);
				curTable[i] = rgb;
			}
			currentHue = hueAdd;
			currentSaturation = saturationAdd;
			currentLightness = lightnessAdd;
			currentContrast = contrastAdd;
		}

		public	function loadDefaultPalette():void
		{
			if (origTable == null)
				origTable = new Vector.<int>(64);
			
			origTable[ 0] = getRgb(124,124,124);
			origTable[ 1] = getRgb(  0,  0,252);
			origTable[ 2] = getRgb(  0,  0,188);
			origTable[ 3] = getRgb( 68, 40,188);
			origTable[ 4] = getRgb(148,  0,132);
			origTable[ 5] = getRgb(168,  0, 32);
			origTable[ 6] = getRgb(168, 16,  0);
			origTable[ 7] = getRgb(136, 20,  0);
			origTable[ 8] = getRgb( 80, 48,  0);
			origTable[ 9] = getRgb(  0,120,  0);
			origTable[10] = getRgb(  0,104,  0);
			origTable[11] = getRgb(  0, 88,  0);
			origTable[12] = getRgb(  0, 64, 88);
			origTable[13] = getRgb(  0,  0,  0);
			origTable[14] = getRgb(  0,  0,  0);
			origTable[15] = getRgb(  0,  0,  0);
			origTable[16] = getRgb(188,188,188);
			origTable[17] = getRgb(  0,120,248);
			origTable[18] = getRgb(  0, 88,248);
			origTable[19] = getRgb(104, 68,252);
			origTable[20] = getRgb(216,  0,204);
			origTable[21] = getRgb(228,  0, 88);
			origTable[22] = getRgb(248, 56,  0);
			origTable[23] = getRgb(228, 92, 16);
			origTable[24] = getRgb(172,124,  0);
			origTable[25] = getRgb(  0,184,  0);
			origTable[26] = getRgb(  0,168,  0);
			origTable[27] = getRgb(  0,168, 68);
			origTable[28] = getRgb(  0,136,136);
			origTable[29] = getRgb(  0,  0,  0);
			origTable[30] = getRgb(  0,  0,  0);
			origTable[31] = getRgb(  0,  0,  0);
			origTable[32] = getRgb(248,248,248);
			origTable[33] = getRgb( 60,188,252);
			origTable[34] = getRgb(104,136,252);
			origTable[35] = getRgb(152,120,248);
			origTable[36] = getRgb(248,120,248);
			origTable[37] = getRgb(248, 88,152);
			origTable[38] = getRgb(248,120, 88);
			origTable[39] = getRgb(252,160, 68);
			origTable[40] = getRgb(248,184,  0);
			origTable[41] = getRgb(184,248, 24);
			origTable[42] = getRgb( 88,216, 84);
			origTable[43] = getRgb( 88,248,152);
			origTable[44] = getRgb(  0,232,216);
			origTable[45] = getRgb(120,120,120);
			origTable[46] = getRgb(  0,  0,  0);
			origTable[47] = getRgb(  0,  0,  0);
			origTable[48] = getRgb(252,252,252);
			origTable[49] = getRgb(164,228,252);
			origTable[50] = getRgb(184,184,248);
			origTable[51] = getRgb(216,184,248);
			origTable[52] = getRgb(248,184,248);
			origTable[53] = getRgb(248,164,192);
			origTable[54] = getRgb(240,208,176);
			origTable[55] = getRgb(252,224,168);
			origTable[56] = getRgb(248,216,120);
			origTable[57] = getRgb(216,248,120);
			origTable[58] = getRgb(184,248,184);
			origTable[59] = getRgb(184,248,216);
			origTable[60] = getRgb(  0,252,252);
			origTable[61] = getRgb(216,216, 16);
			origTable[62] = getRgb(  0,  0,  0);
			origTable[63] = getRgb(  0,  0,  0);

			setEmphasis(0);
			makeTables();
		}
		
		public	function reset():void
		{
			currentEmph = 0;
			currentHue = 0;
			currentSaturation = 0;
			currentLightness = 0;
			setEmphasis(0);
			updatePaletteAll();
		}
	}
}