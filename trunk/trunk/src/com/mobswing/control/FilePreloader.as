package com.mobswing.control
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class FilePreloader extends EventDispatcher
	{
		private static var _this:FilePreloader;
		public	static function getInstance():FilePreloader
		{
			if (_this == null)
				_this = new FilePreloader();
			return _this;
		} 
		
		private var queue:Array;
		private var hash:Object;
		private var loader:URLLoader;
		private var loading:Boolean;
		
		public function FilePreloader()
		{
			queue = new Array();
			hash = new Object();
			loader = new URLLoader();
			loading = false;
			
			loader.addEventListener(Event.COMPLETE, onLoad);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}

		public	function getFile(url:String):Object
		{
			return hash[url];
		}

		public	function reserve(url:String, format:String, id:String):void
		{
			queue.push({"url":url, "format":format, "id":id});
		}
		
		public	function load():void
		{
			if (queue.length < 1)
			{
				loading = false;
				return;
			}
			
			loading = true;
			var o:Object = queue[0];
			loader.dataFormat = o.format as String;
			loader.load(new URLRequest(o.url));
		}
		
		private function onLoad(event:Event):void
		{
			var o:Object = this.queue.shift();
			
			this.hash[o.id] = this.loader.data;
			trace("FilePreloader: load at " + o.url);
			if (this.queue.length > 0)
			{
				load();
			}
			else
			{
				loading = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace("FilePreloader: io error");
			dispatchEvent(event.clone());
		}
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("FilePreloader: load error occur by security reason");
			dispatchEvent(event.clone());
		}
	}
}