package com.mobswing.control
{
	import com.mobswing.model.HiResTimer;
	import com.mobswing.model.Nes;
	import com.mobswing.view.BufferView;
	
	import flash.geom.Point;
	
	public interface IUI
	{
		function getNes():Nes;
		function getJoy1():IInputHandler;
		function getJoy2():IInputHandler;
		function getScreenView():BufferView;
		function getPatternView():BufferView;
		function getSprPalView():BufferView;
		function getImgPalView():BufferView;
		function getNameTableView():BufferView;
		function getTimer():HiResTimer;
		
		function imageReady(skipFrame:Boolean):void;
		function init(showGui:Boolean):void;
		function getWindowCaption():String;
		function setWindowCaption(str:String):void;
		function setTitle(str:String):void;
		function getLocation():Point;
		function getWidth():int;
		function getHeight():int;
		function getRomFileSize():int;
		function destroy():void;
		function println(str:String):void;
		function showLoadProgress(percentComplete:int):void;
		function showErrorMessage(msg:String):void;
	}
}