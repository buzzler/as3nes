package com.mobswing.model
{
	public class Joystick
	{
		public	var UP		:int;
		public	var DOWN	:int;
		public	var LEFT	:int;
		public	var RIGHT	:int;
		public	var START	:int;
		public	var SELECT	:int;
		public	var A		:int;
		public	var B		:int;

		public function Joystick(up:int, down:int, left:int, right:int, start:int, select:int, a:int, b:int)
		{
			this.UP		= up;
			this.DOWN	= down;
			this.LEFT	= left;
			this.RIGHT	= right;
			this.START	= start;
			this.SELECT = select;
			this.A		= a;
			this.B		= b;
		}

	}
}