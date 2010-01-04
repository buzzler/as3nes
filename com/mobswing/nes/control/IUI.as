package com.mobswing.nes.control
{
	import com.mobswing.nes.model.Joystick;
	import com.mobswing.nes.model.Nes;
	import com.mobswing.nes.view.BufferView;
	
	import flash.display.Stage;
	
	public interface IUI
	{
		function getNes():Nes;
		function getJoy1():IInputHandler;
		function getJoy2():IInputHandler;
		function getScreenView():BufferView;
		function getStage():Stage;
		function setJoy1(joystick:Joystick):void;
		function setJoy2(joystick:Joystick):void;
		
		function imageReady(skipFrame:Boolean):void;
		function showErrorMessage(msg:String):void;
	}
}