package com.mobswing.model
{
	public interface ISourceDataLine
	{
		function getBufferSize():int;
		function available():int;
	}
}