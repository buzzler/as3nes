package com.mobswing.model
{
	public class BootInfo
	{
		public	var sound			:Boolean;
		public	var stereo			:Boolean;
		public	var timeemulation	:Boolean;
		public	var joystick1		:Joystick;
		public	var joystick2		:Joystick;

		public function BootInfo(joystick1:Joystick = null, joystick2:Joystick = null, sound:Boolean = false, stereo:Boolean = true, timeemulation:Boolean = true)
		{
			this.sound			= sound;
			this.stereo			= stereo;
			this.timeemulation	= timeemulation;
			this.joystick1		= joystick1;
			this.joystick2		= joystick2;
		}

	}
}