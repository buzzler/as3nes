package com.mobswing.model
{
	public class PaletteTable
	{
		public function PaletteTable()
		{
		}

		public	function loadDefaultPalette():Boolean
		{
			return loadPalette("palettes/ntsc.txt");
		}
		
		public	function loadNTSCPalette():Boolean
		{
			return loadPalette("palettes/pal.txt");
		}
		
		public	function loadPalette(file:String):Boolean
		{
			return true;
		}
		
		public	function reset():void
		{
			;
		}
	}
}