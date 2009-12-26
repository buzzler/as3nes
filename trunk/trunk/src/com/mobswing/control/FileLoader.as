package com.mobswing.control
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class FileLoader extends EventDispatcher
	{
		private var loader:URLLoader;
		private var filename:String;
		private var gui		:IUI;
		public	var data	:Vector.<int>;
		
		public function FileLoader()
		{
		}

		public	function loadFile(filename:String, ui:IUI):void
		{
			this.filename = filename;
			this.gui = ui;
			
			this.loader = new URLLoader();
			this.loader.dataFormat = URLLoaderDataFormat.BINARY;
			this.loader.addEventListener(Event.COMPLETE, onComplete);
			this.loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	onSecurityError);
			this.loader.load(new URLRequest(this.filename));
		}
		
		private function removes():void
		{
			this.loader.removeEventListener(Event.COMPLETE, onComplete);
			this.loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			this.loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,	onSecurityError);
			this.loader = null;
		}

		private function onComplete(event:Event):void
		{
			var ba:ByteArray = this.loader.data as ByteArray;
			var ret:Vector.<int> = new Vector.<int>(ba.length);
			ba.position = 0;
			for (var i:int = 0 ; i < ba.length ; i++)
			{
				ret[i] = ba.readByte() & 255;
			}
			this.data = ret;
			dispatchEvent(new Event(Event.COMPLETE));
			removes();
		}
		
		private function onProgress(event:ProgressEvent):void
		{
			gui.showLoadProgress(Math.round(event.bytesLoaded / event.bytesTotal * 100));
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace("FileLoader: IO Error");
			dispatchEvent(new Event(Event.COMPLETE));
			removes();
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("FileLoader: Security Error");
			dispatchEvent(new Event(Event.COMPLETE));
			removes();
		}
	}
}