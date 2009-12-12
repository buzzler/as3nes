package com.mobswing.control
{
	import com.mobswing.model.HiResTimer;
	import com.mobswing.model.Nes;
	import com.mobswing.view.As3nes;
	import com.mobswing.view.BufferView;
	
	import flash.geom.Point;

	public class MovieClipUI implements IUI
	{
		private var as3nes:As3nes;
		
		public function MovieClipUI(as3nes:As3nes)
		{
			this.as3nes = as3nes;
		}

		public function getNes():Nes
		{
			return null;
		}
		
		public function getJoy1():InputHandler
		{
			return null;
		}
		
		public function getJoy2():InputHandler
		{
			return null;
		}
		
		public function getScreenView():BufferView
		{
			return null;
		}
		
		public function getPatternView():BufferView
		{
			return null;
		}
		
		public function getSprPalView():BufferView
		{
			return null;
		}
		
		public function getImgPalView():BufferView
		{
			return null;
		}
		
		public function getNameTableView():BufferView
		{
			return null;
		}
		
		public function getTimer():HiResTimer
		{
			return null;
		}
		
		public function imageReady(skipFrame:Boolean):void
		{
		}
		
		public function init(showGui:Boolean):void
		{
		}
		
		public function getWindowCaption():String
		{
			return null;
		}
		
		public function setWindowCaption(str:String):void
		{
		}
		
		public function setTitle(str:String):void
		{
		}
		
		public function getLocation():Point
		{
			return null;
		}
		
		public function getWidth():int
		{
			return 0;
		}
		
		public function getHeight():int
		{
			return 0;
		}
		
		public function getRomFileSize():int
		{
			return 0;
		}
		
		public function destroy():void
		{
		}
		
		public function printlm(str:String):void
		{
		}
		
		public function showLoadProgress(percentComplete:int):void
		{
		}
		
		public function showErrorMessage(msg:String):void
		{
		}
		
	}
}