package com.mobswing.model
{
	import __AS3__.vec.Vector;
	
	import flash.errors.EOFError;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class ByteBuffer
	{
		public static const DEBUG			:Boolean = false;
		public static const BO_BIG_ENDIAN	:int = 0;
		public static const BO_LITTLE_ENDIAN:int = 1;
		
		private	var byteOrder		:int = BO_BIG_ENDIAN;
		private var buf				:Vector.<int>;
		private var size			:int;
		private var curPos			:int;
		private var hasBeenErrors	:Boolean;
		private var expandable		:Boolean = true;
		private var expandBy		:int = 4096;
		
		public function ByteBuffer(value:*, byteOrdering:int)
		{
			if (value is int)
				initByInt(value as int, byteOrdering);
			else if (value is ByteArray)
				initByByteArray(value as ByteArray, byteOrdering);
			else if (value is Vector.<int>)
				initByVector(value as Vector.<int>, byteOrdering);
			else
				trace("ByteBuffer: Couldn't create buffer from unknown type");
		}
		
		private function initByInt(size:int, byteOrdering:int):void
		{
			if (size < 1)
				size = 1;
			this.buf = new Vector.<int>(size);
			this.size = size;
			this.byteOrder = byteOrdering;
			this.curPos = 0;
			this.hasBeenErrors = false;
		}
		
		private function initByByteArray(content:ByteArray, byteOrdering:int):void
		{
			this.buf = new Vector.<int>(content.length);
			
			var tmp:int = content.position;
			content.position = 0;
			for(var i:int = 0; i < content.length ; i++)
			{
//				this.buf[i] = content.readByte() & 255;
				this.buf[i] = content.readByte();
			}
			content.position = tmp;
			
			this.size = content.length;
			this.byteOrder = byteOrdering;
			this.curPos = 0;
			this.hasBeenErrors = false;
		}
		
		private	function initByVector(content:Vector.<int>, byteOrdering:int):void
		{
			this.buf = new Vector.<int>(content.length);
			for (var i:int = 0 ; i < content.length ; i++)
			{
				this.buf[i] = content[i];
			}
			this.size = content.length;
			this.byteOrder = byteOrdering;
			this.curPos = 0;
			this.hasBeenErrors = false;
		}
		
		public	function setExpandable(exp:Boolean):void
		{
			this.expandable = exp;
		}
		
		public	function setExpandBy(expBy:int):void
		{
			if(expBy > 1024)
				this.expandBy = expBy;
		}
		
		public	function setByteOrder(byteOrder:int):void
		{
			if(byteOrder>=0 && byteOrder<2)
				this.byteOrder = byteOrder;
		}

		public	function getBytes():ByteArray
		{
			var ret:ByteArray = new ByteArray();
			for(var i:int = 0 ; i < this.buf.length ; i++)
			{
				ret.writeByte(this.buf[i]);
			}
			return ret;
		}
		
		public function getSize():int
		{
			return this.size;
		}
		
		public	function getPos():int
		{
			return this.curPos;
		}
		
		private	function error():void
		{
			this.hasBeenErrors = true;
		}
		
		public	function hasHadErrors():Boolean
		{
			return hasBeenErrors;
		}
		
		public	function clear():void
		{
			for(var i:int = 0 ; i < this.buf.length ; i++)
			{
				this.buf[i] = 0;
			}
			this.curPos=0;
		}
		
		public	function fill(value:int):void
		{
			for(var i:int = 0 ; i < this.size ; i++)
			{
				this.buf[i] = value;
			}
		}
		
		public	function fillRange(start:int, length:int, value:int):Boolean
		{
			if(inRangeAt(start, length))
			{
				for(var i:int = start ; i < (start+length) ; i++)
				{
					this.buf[i] = value;
				}
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function resize(length:int):void
		{
			var newbuf:Vector.<int> = new Vector.<int>(length);
			for (var i:int = 0 ; i < Math.min(length, this.size) ; i++)
			{
				newbuf[i] = this.buf[i];
			}
			
			this.buf = newbuf;
			this.size = length;
		}
		
		public	function resizeToCurrentPos():void
		{
			resize(this.curPos);
		}
		
		public	function expand():void
		{
			expandAt(this.expandBy);
		}
		
		public	function expandAt(byHowMuch:int):void
		{
			resize(this.size + byHowMuch);
		}
		
		public	function goTo(position:int):void
		{
			if(inRange(position))
				this.curPos = position;
			else
				error();
		}
		
		public	function move(howFar:int):void
		{
			this.curPos += howFar;
			if(!inRange(this.curPos))
				this.curPos = size-1;
		}
		
		public	function inRange(pos:int):Boolean
		{
			if(pos >= 0 && pos < this.size)
			{
				return true;
			}
			else
			{
				if(this.expandable)
				{
					expandAt(Math.max(pos+1-this.size , this.expandBy));
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		public	function inRangeAt(pos:int, length:int):Boolean
		{
			if(pos >= 0 && (pos+(length-1) < this.size))
			{
				return true;
			}
			else
			{
				if(this.expandable)
				{
					expandAt(Math.max(pos+length-this.size, this.expandBy));
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		public	function putBoolean(b:Boolean):Boolean
		{
			var ret:Boolean = putBooleanAt(b, this.curPos);
			move(1);
			return ret;
		}
		
		public	function putBooleanAt(b:Boolean, pos:int):Boolean
		{
			if(b)
				return putByteAt(1,pos);
			else
				return putByteAt(0,pos);
		}
		
		public function putByte(value:int):Boolean
		{
			if(inRangeAt(this.curPos, 1))
			{
				this.buf[this.curPos] = value & 255;
				move(1);
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function putByteAt(value:int, pos:int):Boolean
		{
			if(inRangeAt(pos, 1))
			{
				this.buf[pos] = value & 255;
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public function putShort(value:int):Boolean
		{
			var ret:Boolean = putShortAt(value, this.curPos);
			if(ret)
				move(2);
			return ret;
		}
		
		public	function putShortAt(value:int, pos:int):Boolean
		{
			if(inRangeAt(pos,2))
			{
				if(this.byteOrder == BO_BIG_ENDIAN)
				{
					this.buf[pos+0] = ((value>>8)&255);
					this.buf[pos+1] = (value&255);
				}
				else
				{
					this.buf[pos+1] = ((value>>8)&255);
					this.buf[pos+0] = (value&255);
				}
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function putInt(value:int):Boolean
		{
			var ret:Boolean = putIntAt(value, this.curPos);
			if(ret)
				move(4);
			return ret;
		}
		
		public	function putIntAt(value:int, pos:int):Boolean
		{
			if(inRangeAt(pos,4))
			{
				if(this.byteOrder == BO_BIG_ENDIAN)
				{
					this.buf[pos+0] = ((value>>24)&255);
					this.buf[pos+1] = ((value>>16)&255);
					this.buf[pos+2] = ((value>> 8)&255);
					this.buf[pos+3] = ((value    )&255);
				}
				else
				{
					this.buf[pos+3] = ((value>>24)&255);
					this.buf[pos+2] = ((value>>16)&255);
					this.buf[pos+1] = ((value>> 8)&255);
					this.buf[pos+0] = ((value    )&255);
				}
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function putString(value:String):Boolean
		{
			var ret:Boolean = putStringAt(value, this.curPos);
			if(ret)
				move(2 * value.length);
			return ret;
		}
		
		public	function putStringAt(value:String, pos:int):Boolean
		{
			var theChar:int;			
			if(inRangeAt(pos, value.length*2))
			{
				for(var i:int = 0 ; i < value.length; i++)
				{
					theChar = value.charCodeAt(i);
					this.buf[pos+0] = ((theChar>>8)&255);
					this.buf[pos+1] = ((theChar   )&255);
					pos += 2;
				}
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function putChar(value:int):Boolean
		{
			var ret:Boolean = putCharAt(value, this.curPos);
			if(ret)
				move(2);
			return ret;
		}
		
		public	function putCharAt(value:int, pos:int):Boolean
		{
			var tmp:int = value;
			if(inRangeAt(pos, 2))
			{
				if(this.byteOrder == BO_BIG_ENDIAN)
				{
					this.buf[pos+0] = ((tmp>>8)&255);
					this.buf[pos+1] = ((tmp   )&255);
				}
				else
				{
					this.buf[pos+1] = ((tmp>>8)&255);
					this.buf[pos+0] = ((tmp   )&255);
				}
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function putCharAscii(value:int):Boolean
		{
			var ret:Boolean = putCharAsciiAt(value, this.curPos);
			if(ret)
				move(1);
			return ret;
		}
		
		public	function putCharAsciiAt(value:int, pos:int):Boolean
		{
			if(inRange(pos))
			{
				//this.buf[pos] = value & 255;
				this.buf[pos] = value & 65535;
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function putStringAscii(value:String):Boolean
		{
			var ret:Boolean = putStringAsciiAt(value, this.curPos);
			if(ret)
				move(value.length);
			return ret;
		}
		
		public	function putStringAsciiAt(value:String, pos:int):Boolean
		{
			if(inRangeAt(pos, value.length))
			{
				for(var i:int = 0; i < value.length ; i++)
				{
					this.buf[pos] = value.charCodeAt(i);
					pos++;
				}
				return true;
			}
			else
			{
				error();
				return false;
			}
		}
		
		public	function putByteArray(arr:Vector.<int>):Boolean
		{
			if(arr==null)return false;
			
			if(this.buf.length-this.curPos < arr.length)
			{
				resize(this.curPos+arr.length);
			}
			for(var i:int = 0 ; i < arr.length ; i++)
			{
				this.buf[this.curPos+i] = arr[i] & 255;
			}
			this.curPos += arr.length;
			return true;
		}
		
		public	function readByteArray(arr:Vector.<int>):Boolean
		{
			if(arr==null)return false;
			if(this.buf.length-this.curPos < arr.length)return false;
			
			for(var i:int = 0 ; i < arr.length ; i++)
			{
				arr[i] = this.buf[this.curPos+i] & 255;
			}
			this.curPos += arr.length;
			return true;
		}
		
		public	function putShortArray(arr:Vector.<int>):Boolean
		{
			if(arr==null)return false;
			
			if(this.buf.length-this.curPos < arr.length*2)
			{
				resize(this.curPos+arr.length*2);
			}
			if(byteOrder == BO_BIG_ENDIAN)
			{
				for(var i:int = 0 ; i < arr.length ; i++)
				{
					this.buf[this.curPos+0] = ((arr[i]>>8)&255);
					this.buf[this.curPos+1] = ((arr[i]   )&255);
					this.curPos+=2;
				}
			}
			else
			{
				for(var j:int = 0 ; j < arr.length ; j++)
				{
					this.buf[this.curPos+1] = ((arr[j]>>8)&255);
					this.buf[this.curPos+0] = ((arr[j]   )&255);
					this.curPos+=2;
				}
			}
			return true;
		}
		
		public	function toString():String
		{
			var strBuf:Array = new Array();
			var tmp:int;
			for(var i:int = 0 ; i < (this.size-1) ; i+=2)
			{
				tmp = (this.buf[i]<<8)|(this.buf[i+1]);
				strBuf.push(String.fromCharCode(tmp));
			}
			return strBuf.join('');
		}
		
		public	function toStringAscii():String
		{
			var strBuf:Vector.<String> = new Vector.<String>(this.size);
			for(var i:int = 0 ; i < this.size ; i++)
			{
				strBuf[i] = String.fromCharCode(this.buf[i]);
			}
			return strBuf.join('');
		}
		
		public	function readBoolean():Boolean
		{
			var ret:Boolean = readBooleanAt(this.curPos);
			move(1);
			return ret;
		}
		
		public	function readBooleanAt(pos:int):Boolean
		{
			return (readByteAt(pos)==1);
		}
		
		public	function readByte():int
		{
			var ret:int = readByteAt(this.curPos);
			move(1);
			return ret;
		}
		
		public	function readByteAt(pos:int):int
		{
			if(inRange(pos))
			{
				return this.buf[pos] & 255;
			}
			else
			{
				error();
				throw new EOFError();
			}
		}
		
		public	function readShort():int
		{
			var ret:int = readShortAt(curPos);
			move(2);
			return ret;
		}
		
		public	function readShortAt(pos:int):int
		{
			if(inRangeAt(pos, 2))
			{
				if(this.byteOrder == BO_BIG_ENDIAN)
					return ((this.buf[pos]<<8)|(this.buf[pos+1]));
				else
					return ((this.buf[pos+1]<<8)|(this.buf[pos]));
			}
			else
			{
				error();
				throw new EOFError();
			}
		}
		
		public	function readInt():int
		{
			var ret:int = readIntAt(this.curPos);
			move(4);
			return ret;
		}
		
		public	function readIntAt(pos:int):int
		{
			var ret:int = 0;
			if (inRangeAt(pos, 4))
			{
				if(this.byteOrder == BO_BIG_ENDIAN)
				{
					ret |= (this.buf[pos+0]<<24);
					ret |= (this.buf[pos+1]<<16);
					ret |= (this.buf[pos+2]<< 8);
					ret |= (this.buf[pos+3]    );
				}
				else
				{
					ret |= (this.buf[pos+3]<<24);
					ret |= (this.buf[pos+2]<<16);
					ret |= (this.buf[pos+1]<< 8);
					ret |= (this.buf[pos+0]    );
				}
				return ret;
			}
			else
			{
				error();
				throw new EOFError();
			}
		}
		
		public	function readChar():int
		{
			var ret:int = readCharAt(this.curPos);
			move(2);
			return ret;
		}
		
		public	function readCharAt(pos:int):int
		{
			if(inRangeAt(pos, 2))
			{
				return readShortAt(pos);
			}
			else
			{
				error();
				throw new EOFError();
			}
		}
		
		public	function readCharAscii():int
		{
			var ret:int = readCharAsciiAt(this.curPos);
			move(1);
			return ret;
		}
		
		public	function readCharAsciiAt(pos:int):int
		{
			if(inRangeAt(pos, 1))
			{
				return readByteAt(pos)&255;
			}
			else
			{
				error();
				throw new EOFError();
			}
		}
		
		public	function readString(length:int):String
		{
			if(length > 0)
			{
				var ret:String = readStringAt(this.curPos, length);
				move(ret.length*2);
				return ret;
			}
			else
			{
				return '';
			}
		}
		
		public	function readStringAt(pos:int, length:int):String
		{
			var tmp:Vector.<String>;
			if (inRangeAt(pos, length*2) && length>0)
			{
				 tmp = new Vector.<String>(length);
				 for(var i:int = 0 ; i < length ; i++)
				 {
				 	tmp[i] = String.fromCharCode(readCharAt(pos+i*2));
				 }
				 return tmp.join('');
			}
			else
			{
				throw new EOFError();
			}
		}
		
		public	function readStringWithShortLength():String
		{
			var ret:String = readStringWithShortLengthAt(this.curPos);
			move(ret.length*2+2);
			return ret;
		}
		
		public	function readStringWithShortLengthAt(pos:int):String
		{
			var len:int;
			if(inRangeAt(pos, 2))
			{
				len = readShortAt(pos);
				if (len > 0)
					return readStringAt(pos + 2, len);
				else
					return '';
			}
			else
			{
				throw new EOFError();
			}
		}
		
		public	function readStringAscii(length:int):String
		{
			var ret:String = readStringAsciiAt(this.curPos, length);
			move(ret.length);
			return ret;
		}
		
		public	function readStringAsciiAt(pos:int, length:int):String
		{
			var tmp:Vector.<String>;
			if (inRangeAt(pos, length) && length > 0)
			{
				tmp = new Vector.<String>(length);
				for(var i:int = 0 ; i < length ; i++)
				{
					tmp[i] = String.fromCharCode(readCharAsciiAt(pos + i));
				}
				return tmp.join('');
			}
			else
			{
				throw new EOFError();
			}
		}
		
		public	function readStringAsciiWithShortLength():String
		{
			var ret:String = readStringAsciiWithShortLengthAt(this.curPos);
			move(ret.length + 2);
			return ret;
		}
		
		public	function readStringAsciiWithShortLengthAt(pos:int):String
		{
			var len:int;
			if (inRangeAt(pos, 2))
			{
				len = readShortAt(pos);
				if (len > 0)
					return readStringAsciiAt(pos+2, len);
				else
					return '';
			}
			else
			{
				throw new EOFError();
			}
		}
		
		private	function expandShortArray(array:Vector.<int>, size:int):Vector.<int>
		{
			var i:int;
			var newArr:Vector.<int> = new Vector.<int>(array.length + size);
			if (size > 0)
			{
				for (i = 0 ; i < array.length ; i++)
				{
					newArr[i] = array[i];
				}
			}
			else
			{
				for (i = 0 ; i < newArr.length ; i++)
				{
					newArr[i] = array[i];
				}
			}
			return newArr;
		}
		
		public	function crop():void
		{
			if (this.curPos > 0)
			{
				if (this.curPos < this.buf.length)
				{
					var newBuf:Vector.<int> = new Vector.<int>(curPos);
					for (var i:int = 0 ; i < this.curPos ; i++)
					{
						newBuf[i] = this.buf[i];
					}
					this.buf = newBuf;
				}
			}
			else
			{
				trace("Could not crop buffer, as the current position is 0. The buffer may not be empty.");
			}
		}		
		
		public	static function asciiEncode(buf:ByteBuffer):ByteBuffer
		{
			var data:Vector.<int> = buf.buf;
			var enc:Vector.<int> = new Vector.<int>(buf.getSize()*2);
			var encpos:int = 0;
			var tmp:int;
			for (var i:int = 0 ; i < data.length ; i++)
			{
				tmp = data[i];
				enc[encpos  ] = (65+(tmp   ) & 0xF);
				enc[encpos+1] = (65+(tmp>>4) & 0xF);
				encpos += 2;
			}
			return new ByteBuffer(enc,ByteBuffer.BO_BIG_ENDIAN);
		}
		
		public	static function asciiDecode(buf:ByteBuffer):ByteBuffer
		{
			return null;
		}
	}
}