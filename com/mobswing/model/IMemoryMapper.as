package com.mobswing.model
{
	public interface IMemoryMapper
	{
		function init(nes:Nes):void;
		function loadROM(rom:ROM):void;
		function write(address:int, value:int):void;
		function load(address:int):int;
		function joy1Read():int;
		function joy2Read():int;
		function reset():void;
		function setGameGenieState(value:Boolean):void;
		function clockIrqCounter():void;
		function loadBatteryRam():void;
		function destroy():void;
		function stateLoad(buf:ByteBuffer):void;
		function stateSave(buf:ByteBuffer):void;
		function setMouseState(pressed:Boolean, x:int, y:int):void;
		function latchAccess(address:int):void;
	}
}