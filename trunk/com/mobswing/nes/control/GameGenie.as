package com.mobswing.nes.control
{
	import __AS3__.vec.Vector;
	
	public class GameGenie
	{
		public static var TYPE_6CHAR:int = 0;
		public static var TYPE_8CHAR:int = 1;
		
		public	var addressMatch:Vector.<Boolean>;
		
		public function GameGenie()
		{
		}

		public	function getCodeCount():int
		{
			return 0;
		}
		
		public	function getCodeIndex(address:int):int
		{
			return 0;
		}
		
		public	function getCodeType(index:int):int
		{
			return 0;
		}
		
		public	function getCodeValue(index:int):int
		{
			return 0;
		}
		
		public	function getCodeCompare(index:int):int
		{
			return 0;
		}
	}
}