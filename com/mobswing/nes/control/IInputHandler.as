package com.mobswing.control
{
	public interface IInputHandler
	{
		function getKeyState(padKey:int):int;
		function mapKey(padKey:int, deviceKey:int):void;
		function reset():void;
	}
}