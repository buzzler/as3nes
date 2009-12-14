package com.mobswing.view
{
	import com.mobswing.control.KbInputHandler;
	
	import flash.display.Sprite;

	public class ASPanel extends Sprite
	{
		private var _mask:Sprite;
		
		public function ASPanel()
		{
			super();
			this._mask = new Sprite();
			this._mask.graphics.beginFill(0);
			this._mask.graphics.drawRect(0,0,1,1);
			this._mask.graphics.endFill();

			this.mask = this._mask;
		}

		public	function addKeyListener(listener:KbInputHandler):void
		{
			;
		}
		
		public	function getWidth():int
		{
			return this.width;
		}
		
		public	function getHeight():int
		{
			return this.height;
		}

		public	function setSize(width:int, height:int):void
		{
			this.width = width;
			this.height = height;
		}
		
		public	function setBounds(x:int, y:int, width:int, height:int):void
		{
			this._mask.x = x;
			this._mask.y = y;
			this._mask.width = width;
			this._mask.height = height;
		}
	}
}