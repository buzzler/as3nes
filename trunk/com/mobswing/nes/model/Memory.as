package com.mobswing.nes.model
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class Memory
	{
		public	var mem:Vector.<int>;
		public	var memLength:int;
		public	var nes:Nes;
		
		private var dumpTarget:Object;
		
		public	function Memory(nes:Nes, byteCount:int)
		{
			this.nes = nes;
			this.mem = new Vector.<int>(byteCount);
			this.memLength = byteCount;
		}

		public	function stateLoad(buf:ByteBuffer):void
		{
			if (this.mem == null)
				this.mem = new Vector.<int>(this.memLength);
			buf.readByteArray(this.mem);
		}
		
		public	function stateSave(buf:ByteBuffer):void
		{
			buf.readByteArray(this.mem);
		}
		
		public	function reset():void
		{
			for (var i:int = 0 ; i < this.memLength ; i++)
			{
				this.mem[i] = 0;
			}
		}
		
		public	function getMemSize():int
		{
			return this.memLength;
		}
		
		public	function write(address:int, value:int):void
		{
			this.mem[address] = value;
		}
		
		public	function writeArray(address:int, array:Vector.<int>, length:int):void
		{
			if (address + length > this.mem.length) return;
			
			for (var i:int = 0 ; i < length ; i++)
			{
				this.mem[address+i] = array[i];
			}
		}
		
		public	function writeArrayAt(address:int, array:Vector.<int>, arrayOffset:int, length:int):void
		{
			if (address + length > this.mem.length) return;
			
			for (var i:int = 0 ; i < length ; i++)
			{
				this.mem[address+i] = array[arrayOffset + i];
			}
		}
		
		public	function load(address:int):int
		{
			return this.mem[address];
		}
		
		public	function dump(file:String):void
		{
			this.dumpAt(file, 0, this.memLength);
		}
		
		public	function dumpAt(file:String, offset:int, length:int):void
		{
			this.dumpTarget = {'file':file, 'offset':offset, 'length':int};
			
			var ref:FileReference = new FileReference();
			ref.addEventListener(Event.SELECT, onSelectDump);
			ref.browse([new FileFilter("Famicom Memory Dump", "*.fmd")]);
		}
		
		private function onSelectDump(event:Event):void
		{
			var ref:FileReference = event.target as FileReference;
			ref.removeEventListener(Event.SELECT, onSelectDump);
			
			var file:String	= this.dumpTarget['file'] as String;
			var offset:int	= this.dumpTarget['offset'] as int;
			var length:int 	= this.dumpTarget['length'] as int;
			var ba:ByteArray= new ByteArray();
			for (var i:int = 0 ; i < length ; i++)
			{
				ba.writeShort(this.mem[offset+i]);
			}
			
			try
			{
				ref.save(ba, file);
				trace("Memory dumped to file "+file+".");
			}
			catch (e:IOError)
			{
				trace("Memory dump to file: IO Error!");
			}
		}
		
		public	function destroy():void
		{
			this.nes = null;
			this.mem = null;
		}
	}
}