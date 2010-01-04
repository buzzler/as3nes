package com.mobswing.nes.model
{
	public class Mapper034 extends MapperDefault
	{
		public function Mapper034()
		{
			super();
		}

		override public	function init(nes:Nes):void
		{
		    super.init(nes);
		}
		
		override public	function write(address:int, value:int):void
		{
		    if (address < 0x8000)
		    {
		        super.write(address, value);
		    }
		    else
		    {
		        load32kRomBank(value, 0x8000);
		    }
		}		
	}
}