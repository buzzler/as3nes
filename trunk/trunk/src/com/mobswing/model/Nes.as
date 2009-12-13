package com.mobswing.model
{
	import com.mobswing.control.GameGenie;
	import com.mobswing.control.IUI;
	
	public class Nes
	{
		public	var gui			:IUI;
		public	var cpu			:CPU;
		public	var ppu			:PPU;
		public	var papu		:PAPU;
		public	var cpuMem		:Memory;
		public	var ppuMem		:Memory;
		public	var sprMem		:Memory;
		public	var memMapper	:IMemoryMapper;
		public	var palTable	:PaletteTable;
		public	var rom			:ROM;
		public	var gameGenie	:GameGenie;
		
		public	var romFile		:String;
		private	var _isRunning	:Boolean = false;

		public function Nes(gui:IUI)
		{
		}

		public	function stateLoad(buf:ByteBuffer):Boolean
		{
			var continueEmulationL:Boolean = false;
			var success:Boolean;
			
			return success;
		}
		
		public	function stateSave(buf:ByteBuffer):void
		{
			;
		}
		
		public	function isRunning():Boolean
		{
			return this._isRunning;
		}
		
		public	function startEmulation():void
		{
			;
		}
		
		public	function stopEmulation():void
		{
			;
		}
		
		public	function reloadRom():void
		{
			;
		}
		
		public	function clearCPUMemory():void
		{
			;
		}
		
		public	function setGameGenieState(enable:Boolean):void
		{
			;
		}
		
		public	function getCpu():CPU
		{
			return this.cpu;
		}
		
		public	function getPpu():PPU
		{
			return this.ppu;
		}
		
		public	function getPapu():PAPU
		{
			return this.papu;
		}
		
		public	function getCpuMemory():Memory
		{
			return this.cpuMem;
		}
		
		public	function getPpuMemory():Memory
		{
			return this.ppuMem;
		}
		
		public	function getSprMemory():Memory
		{
			return this.sprMem;
		}
		
		public	function getRom():ROM
		{
			return rom;
		}

		public	function getGui():IUI
		{
			return this.gui; 
		}
		
		public	function getMemoryMapper():IMemoryMapper
		{
			return this.memMapper;
		}
		
		public	function getGameGenie():GameGenie
		{
			return this.gameGenie;
		}
		
		public	function loadRom(file:String):Boolean
		{
			return false;
		}
		
		public	function reset():void
		{
			;
		}
		
		public	function enableSound(enable:Boolean):void
		{
			;
		}
		
		public	function setFrameRate(rate:int):void
		{
			;
		}
		
		public	function destroy():void
		{
			;
		}
	}
}