package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	public class ROM
	{
		public	var batteryRam:Boolean;
		
		public function ROM(nes:Nes)
		{
		}

		public	function load(filename:String):void
		{
			;
		}

		public	function isValid():Boolean
		{
			return true;
		}
		
		public	function createMapper():IMemoryMapper
		{
			return null;
		}
		
		public	function getMirroringType():int
		{
			return 0;
		}
		
		public	function closeRom():void
		{
			;
		}
		
		public	function writeBatteryRam(address:int, value:int):void
		{
			;
		}
		
		public	function getRomBank(bank:int):Vector.<int>
		{
			return null;
		}
		
		public	function getRomBankCount():int
		{
			return 0;
		}
		
		public	function getVromBank(bank:int):Vector.<int>
		{
			return null;
		}
		
		public	function getVromBankTiles(bank:int):Vector.<Tile>
		{
			return null;
		}
		
		public	function getVromBankCount():int
		{
			return 0;
		}
		
		public	function getBatteryRam():Vector.<int>
		{
			return null;
		}
		
		public	function destroy():void
		{
			;
		}
	}
}