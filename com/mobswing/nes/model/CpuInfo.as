package com.mobswing.nes.model
{
	import __AS3__.vec.Vector;
	
	public class CpuInfo
	{
		private static var opdata	:Vector.<int>;
		private static var instname	:Vector.<String>;
		private static var addrDesc	:Vector.<String>;
		public	static var cycTable	:Vector.<int>;

		public	static const INS_ADC:int = 0;
		public	static const INS_AND:int = 1;
		public	static const INS_ASL:int = 2;
		public	static const INS_BCC:int = 3;
		public	static const INS_BCS:int = 4;
		public	static const INS_BEQ:int = 5;
		public	static const INS_BIT:int = 6;
		public	static const INS_BMI:int = 7;
		public	static const INS_BNE:int = 8;
		public	static const INS_BPL:int = 9;
		public	static const INS_BRK:int = 10;
		public	static const INS_BVC:int = 11;
		public	static const INS_BVS:int = 12;
		public	static const INS_CLC:int = 13;
		public	static const INS_CLD:int = 14;
		public	static const INS_CLI:int = 15;
		public	static const INS_CLV:int = 16;
		public	static const INS_CMP:int = 17;
		public	static const INS_CPX:int = 18;
		public	static const INS_CPY:int = 19;
		public	static const INS_DEC:int = 20;
		public	static const INS_DEX:int = 21;
		public	static const INS_DEY:int = 22;
		public	static const INS_EOR:int = 23;
		public	static const INS_INC:int = 24;
		public	static const INS_INX:int = 25;
		public	static const INS_INY:int = 26;
		public	static const INS_JMP:int = 27;
		public	static const INS_JSR:int = 28;
		public	static const INS_LDA:int = 29;
		public	static const INS_LDX:int = 30;
		public	static const INS_LDY:int = 31;
		public	static const INS_LSR:int = 32;
		public	static const INS_NOP:int = 33;
		public	static const INS_ORA:int = 34;
		public	static const INS_PHA:int = 35;
		public	static const INS_PHP:int = 36;
		public	static const INS_PLA:int = 37;
		public	static const INS_PLP:int = 38;
		public	static const INS_ROL:int = 39;
		public	static const INS_ROR:int = 40;
		public	static const INS_RTI:int = 41;
		public	static const INS_RTS:int = 42;
		public	static const INS_SBC:int = 43;
		public	static const INS_SEC:int = 44;
		public	static const INS_SED:int = 45;
		public	static const INS_SEI:int = 46;
		public	static const INS_STA:int = 47;
		public	static const INS_STX:int = 48;
		public	static const INS_STY:int = 49;
		public	static const INS_TAX:int = 50;
		public	static const INS_TAY:int = 51;
		public	static const INS_TSX:int = 52;
		public	static const INS_TXA:int = 53;
		public	static const INS_TXS:int = 54;
		public	static const INS_TYA:int = 55;
		public	static const INS_DUMMY:int = 56;
		
		public	static const ADDR_ZP		:int = 0;
		public	static const ADDR_REL		:int = 1;
		public	static const ADDR_IMP		:int = 2;
		public	static const ADDR_ABS		:int = 3;
		public	static const ADDR_ACC		:int = 4;
		public	static const ADDR_IMM		:int = 5;
		public	static const ADDR_ZPX		:int = 6;
		public	static const ADDR_ZPY		:int = 7;
		public	static const ADDR_ABSX		:int = 8;
		public	static const ADDR_ABSY		:int = 9;
		public	static const ADDR_PREIDXIND	:int = 10;
		public	static const ADDR_POSTIDXIND:int = 11;
		public	static const ADDR_INDABS	:int = 12;
		
		public	function CpuInfo()
		{
		}

		public	static function getOpData():Vector.<int>
		{
			if (opdata == null)
				initOpData();
			return opdata;
		}

		public	static function getInstNames():Vector.<String>
		{
			if (instname == null)
				initInstNames();
			return instname;
		}

		public	static function getInstName(inst:int):String
		{
			if (instname == null)
				initInstNames();

			if (inst < instname.length)
				return instname[inst];
			else
				return "???";
		}
		
		
		public	static function getAddressModeNames():Vector.<String>
		{
			if (addrDesc == null)
				initAddrDesc();
			return addrDesc;
		}
		
		
		public	static function getAddressModeName(addrMode:int):String
		{
			if (addrDesc == null)
				initAddrDesc();
			if ((addrMode >= 0) && (addrMode < addrDesc.length))
				return addrDesc[addrMode];
			return "???";
		}
		
		
		private static function initOpData():void
		{
			opdata = new Vector.<int>(256);

			for(var i:int = 0 ; i < 256 ; i++)
				opdata[i]=0xFF;

			setOp(INS_ADC,0x69,ADDR_IMM,2,2);
			setOp(INS_ADC,0x65,ADDR_ZP,2,3);
			setOp(INS_ADC,0x75,ADDR_ZPX,2,4);
			setOp(INS_ADC,0x6D,ADDR_ABS,3,4);
			setOp(INS_ADC,0x7D,ADDR_ABSX,3,4);
			setOp(INS_ADC,0x79,ADDR_ABSY,3,4);
			setOp(INS_ADC,0x61,ADDR_PREIDXIND,2,6);
			setOp(INS_ADC,0x71,ADDR_POSTIDXIND,2,5);
			
			// AND:
			setOp(INS_AND,0x29,ADDR_IMM,2,2);
			setOp(INS_AND,0x25,ADDR_ZP,2,3);
			setOp(INS_AND,0x35,ADDR_ZPX,2,4);
			setOp(INS_AND,0x2D,ADDR_ABS,3,4);
			setOp(INS_AND,0x3D,ADDR_ABSX,3,4);
			setOp(INS_AND,0x39,ADDR_ABSY,3,4);
			setOp(INS_AND,0x21,ADDR_PREIDXIND,2,6);
			setOp(INS_AND,0x31,ADDR_POSTIDXIND,2,5);
			
			// ASL:
			setOp(INS_ASL,0x0A,ADDR_ACC,1,2);
			setOp(INS_ASL,0x06,ADDR_ZP,2,5);
			setOp(INS_ASL,0x16,ADDR_ZPX,2,6);
			setOp(INS_ASL,0x0E,ADDR_ABS,3,6);
			setOp(INS_ASL,0x1E,ADDR_ABSX,3,7);
			
			// BCC:
			setOp(INS_BCC,0x90,ADDR_REL,2,2);
			
			// BCS:
			setOp(INS_BCS,0xB0,ADDR_REL,2,2);
			
			// BEQ:
			setOp(INS_BEQ,0xF0,ADDR_REL,2,2);
			
			// BIT:
			setOp(INS_BIT,0x24,ADDR_ZP,2,3);
			setOp(INS_BIT,0x2C,ADDR_ABS,3,4);
			
			// BMI:
			setOp(INS_BMI,0x30,ADDR_REL,2,2);
			
			// BNE:
			setOp(INS_BNE,0xD0,ADDR_REL,2,2);
			
			// BPL:
			setOp(INS_BPL,0x10,ADDR_REL,2,2);
			
			// BRK:
			setOp(INS_BRK,0x00,ADDR_IMP,1,7);
			
			// BVC:
			setOp(INS_BVC,0x50,ADDR_REL,2,2);
			
			// BVS:
			setOp(INS_BVS,0x70,ADDR_REL,2,2);
			
			// CLC:
			setOp(INS_CLC,0x18,ADDR_IMP,1,2);
			
			// CLD:
			setOp(INS_CLD,0xD8,ADDR_IMP,1,2);
			
			// CLI:
			setOp(INS_CLI,0x58,ADDR_IMP,1,2);
			
			// CLV:
			setOp(INS_CLV,0xB8,ADDR_IMP,1,2);
			
			// CMP:
			setOp(INS_CMP,0xC9,ADDR_IMM,2,2);
			setOp(INS_CMP,0xC5,ADDR_ZP,2,3);
			setOp(INS_CMP,0xD5,ADDR_ZPX,2,4);
			setOp(INS_CMP,0xCD,ADDR_ABS,3,4);
			setOp(INS_CMP,0xDD,ADDR_ABSX,3,4);
			setOp(INS_CMP,0xD9,ADDR_ABSY,3,4);
			setOp(INS_CMP,0xC1,ADDR_PREIDXIND,2,6);
			setOp(INS_CMP,0xD1,ADDR_POSTIDXIND,2,5);
			
			// CPX:
			setOp(INS_CPX,0xE0,ADDR_IMM,2,2);
			setOp(INS_CPX,0xE4,ADDR_ZP,2,3);
			setOp(INS_CPX,0xEC,ADDR_ABS,3,4);
			
			// CPY:
			setOp(INS_CPY,0xC0,ADDR_IMM,2,2);
			setOp(INS_CPY,0xC4,ADDR_ZP,2,3);
			setOp(INS_CPY,0xCC,ADDR_ABS,3,4);
			
			// DEC:
			setOp(INS_DEC,0xC6,ADDR_ZP,2,5);
			setOp(INS_DEC,0xD6,ADDR_ZPX,2,6);
			setOp(INS_DEC,0xCE,ADDR_ABS,3,6);
			setOp(INS_DEC,0xDE,ADDR_ABSX,3,7);
			
			// DEX:
			setOp(INS_DEX,0xCA,ADDR_IMP,1,2);
			
			// DEY:
			setOp(INS_DEY,0x88,ADDR_IMP,1,2);
			
			// EOR:
			setOp(INS_EOR,0x49,ADDR_IMM,2,2);
			setOp(INS_EOR,0x45,ADDR_ZP,2,3);
			setOp(INS_EOR,0x55,ADDR_ZPX,2,4);
			setOp(INS_EOR,0x4D,ADDR_ABS,3,4);
			setOp(INS_EOR,0x5D,ADDR_ABSX,3,4);
			setOp(INS_EOR,0x59,ADDR_ABSY,3,4);
			setOp(INS_EOR,0x41,ADDR_PREIDXIND,2,6);
			setOp(INS_EOR,0x51,ADDR_POSTIDXIND,2,5);
			
			// INC:
			setOp(INS_INC,0xE6,ADDR_ZP,2,5);
			setOp(INS_INC,0xF6,ADDR_ZPX,2,6);
			setOp(INS_INC,0xEE,ADDR_ABS,3,6);
			setOp(INS_INC,0xFE,ADDR_ABSX,3,7);
			
			// INX:
			setOp(INS_INX,0xE8,ADDR_IMP,1,2);
			
			// INY:
			setOp(INS_INY,0xC8,ADDR_IMP,1,2);
			
			// JMP:
			setOp(INS_JMP,0x4C,ADDR_ABS,3,3);
			setOp(INS_JMP,0x6C,ADDR_INDABS,3,5);
			
			// JSR:
			setOp(INS_JSR,0x20,ADDR_ABS,3,6);
			
			// LDA:
			setOp(INS_LDA,0xA9,ADDR_IMM,2,2);
			setOp(INS_LDA,0xA5,ADDR_ZP,2,3);
			setOp(INS_LDA,0xB5,ADDR_ZPX,2,4);
			setOp(INS_LDA,0xAD,ADDR_ABS,3,4);
			setOp(INS_LDA,0xBD,ADDR_ABSX,3,4);
			setOp(INS_LDA,0xB9,ADDR_ABSY,3,4);
			setOp(INS_LDA,0xA1,ADDR_PREIDXIND,2,6);
			setOp(INS_LDA,0xB1,ADDR_POSTIDXIND,2,5);
			
			
			// LDX:
			setOp(INS_LDX,0xA2,ADDR_IMM,2,2);
			setOp(INS_LDX,0xA6,ADDR_ZP,2,3);
			setOp(INS_LDX,0xB6,ADDR_ZPY,2,4);
			setOp(INS_LDX,0xAE,ADDR_ABS,3,4);
			setOp(INS_LDX,0xBE,ADDR_ABSY,3,4);
			
			// LDY:
			setOp(INS_LDY,0xA0,ADDR_IMM,2,2);
			setOp(INS_LDY,0xA4,ADDR_ZP,2,3);
			setOp(INS_LDY,0xB4,ADDR_ZPX,2,4);
			setOp(INS_LDY,0xAC,ADDR_ABS,3,4);
			setOp(INS_LDY,0xBC,ADDR_ABSX,3,4);
			
			// LSR:
			setOp(INS_LSR,0x4A,ADDR_ACC,1,2);
			setOp(INS_LSR,0x46,ADDR_ZP,2,5);
			setOp(INS_LSR,0x56,ADDR_ZPX,2,6);
			setOp(INS_LSR,0x4E,ADDR_ABS,3,6);
			setOp(INS_LSR,0x5E,ADDR_ABSX,3,7);
			
			// NOP:
			setOp(INS_NOP,0xEA,ADDR_IMP,1,2);
			
			// ORA:
			setOp(INS_ORA,0x09,ADDR_IMM,2,2);
			setOp(INS_ORA,0x05,ADDR_ZP,2,3);
			setOp(INS_ORA,0x15,ADDR_ZPX,2,4);
			setOp(INS_ORA,0x0D,ADDR_ABS,3,4);
			setOp(INS_ORA,0x1D,ADDR_ABSX,3,4);
			setOp(INS_ORA,0x19,ADDR_ABSY,3,4);
			setOp(INS_ORA,0x01,ADDR_PREIDXIND,2,6);
			setOp(INS_ORA,0x11,ADDR_POSTIDXIND,2,5);
			
			// PHA:
			setOp(INS_PHA,0x48,ADDR_IMP,1,3);
			
			// PHP:
			setOp(INS_PHP,0x08,ADDR_IMP,1,3);
			
			// PLA:
			setOp(INS_PLA,0x68,ADDR_IMP,1,4);
			
			// PLP:
			setOp(INS_PLP,0x28,ADDR_IMP,1,4);
			
			// ROL:
			setOp(INS_ROL,0x2A,ADDR_ACC,1,2);
			setOp(INS_ROL,0x26,ADDR_ZP,2,5);
			setOp(INS_ROL,0x36,ADDR_ZPX,2,6);
			setOp(INS_ROL,0x2E,ADDR_ABS,3,6);
			setOp(INS_ROL,0x3E,ADDR_ABSX,3,7);
			
			// ROR:
			setOp(INS_ROR,0x6A,ADDR_ACC,1,2);
			setOp(INS_ROR,0x66,ADDR_ZP,2,5);
			setOp(INS_ROR,0x76,ADDR_ZPX,2,6);
			setOp(INS_ROR,0x6E,ADDR_ABS,3,6);
			setOp(INS_ROR,0x7E,ADDR_ABSX,3,7);
			
			// RTI:
			setOp(INS_RTI,0x40,ADDR_IMP,1,6);
			
			// RTS:
			setOp(INS_RTS,0x60,ADDR_IMP,1,6);
			
			// SBC:
			setOp(INS_SBC,0xE9,ADDR_IMM,2,2);
			setOp(INS_SBC,0xE5,ADDR_ZP,2,3);
			setOp(INS_SBC,0xF5,ADDR_ZPX,2,4);
			setOp(INS_SBC,0xED,ADDR_ABS,3,4);
			setOp(INS_SBC,0xFD,ADDR_ABSX,3,4);
			setOp(INS_SBC,0xF9,ADDR_ABSY,3,4);
			setOp(INS_SBC,0xE1,ADDR_PREIDXIND,2,6);
			setOp(INS_SBC,0xF1,ADDR_POSTIDXIND,2,5);
			
			// SEC:
			setOp(INS_SEC,0x38,ADDR_IMP,1,2);
			
			// SED:
			setOp(INS_SED,0xF8,ADDR_IMP,1,2);
			
			// SEI:
			setOp(INS_SEI,0x78,ADDR_IMP,1,2);
			
			// STA:
			setOp(INS_STA,0x85,ADDR_ZP,2,3);
			setOp(INS_STA,0x95,ADDR_ZPX,2,4);
			setOp(INS_STA,0x8D,ADDR_ABS,3,4);
			setOp(INS_STA,0x9D,ADDR_ABSX,3,5);
			setOp(INS_STA,0x99,ADDR_ABSY,3,5);
			setOp(INS_STA,0x81,ADDR_PREIDXIND,2,6);
			setOp(INS_STA,0x91,ADDR_POSTIDXIND,2,6);
			
			// STX:
			setOp(INS_STX,0x86,ADDR_ZP,2,3);
			setOp(INS_STX,0x96,ADDR_ZPY,2,4);
			setOp(INS_STX,0x8E,ADDR_ABS,3,4);
			
			// STY:
			setOp(INS_STY,0x84,ADDR_ZP,2,3);
			setOp(INS_STY,0x94,ADDR_ZPX,2,4);
			setOp(INS_STY,0x8C,ADDR_ABS,3,4);
			
			// TAX:
			setOp(INS_TAX,0xAA,ADDR_IMP,1,2);
			
			// TAY:
			setOp(INS_TAY,0xA8,ADDR_IMP,1,2);
			
			// TSX:
			setOp(INS_TSX,0xBA,ADDR_IMP,1,2);
			
			// TXA:
			setOp(INS_TXA,0x8A,ADDR_IMP,1,2);
			
			// TXS:
			setOp(INS_TXS,0x9A,ADDR_IMP,1,2);
			
			// TYA:
			setOp(INS_TYA,0x98,ADDR_IMP,1,2);
			
			
			cycTable = Vector.<int>([
			/*0x00*/ 7,6,2,8,3,3,5,5,3,2,2,2,4,4,6,6,
			/*0x10*/ 2,5,2,8,4,4,6,6,2,4,2,7,4,4,7,7,
			/*0x20*/ 6,6,2,8,3,3,5,5,4,2,2,2,4,4,6,6,
			/*0x30*/ 2,5,2,8,4,4,6,6,2,4,2,7,4,4,7,7,
			/*0x40*/ 6,6,2,8,3,3,5,5,3,2,2,2,3,4,6,6,
			/*0x50*/ 2,5,2,8,4,4,6,6,2,4,2,7,4,4,7,7,
			/*0x60*/ 6,6,2,8,3,3,5,5,4,2,2,2,5,4,6,6,
			/*0x70*/ 2,5,2,8,4,4,6,6,2,4,2,7,4,4,7,7,
			/*0x80*/ 2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4,
			/*0x90*/ 2,6,2,6,4,4,4,4,2,5,2,5,5,5,5,5,
			/*0xA0*/ 2,6,2,6,3,3,3,3,2,2,2,2,4,4,4,4,
			/*0xB0*/ 2,5,2,5,4,4,4,4,2,4,2,4,4,4,4,4,
			/*0xC0*/ 2,6,2,8,3,3,5,5,2,2,2,2,4,4,6,6,
			/*0xD0*/ 2,5,2,8,4,4,6,6,2,4,2,7,4,4,7,7,
			/*0xE0*/ 2,6,3,8,3,3,5,5,2,2,2,2,4,4,6,6,
			/*0xF0*/ 2,5,2,8,4,4,6,6,2,4,2,7,4,4,7,7,
			]);
		}

		private static function setOp(inst:int, op:int, addr:int, size:int, cycles:int):void
		{
			opdata[op] = 
				((inst  &0xFF)    )| 
				((addr  &0xFF)<< 8)| 
				((size  &0xFF)<<16)| 
				((cycles&0xFF)<<24);
		}
		
		private static function initInstNames():void
		{
			instname = new Vector.<String>(56);
			
			instname[ 0] = "ADC";
			instname[ 1] = "AND";
			instname[ 2] = "ASL";
			instname[ 3] = "BCC";
			instname[ 4] = "BCS";
			instname[ 5] = "BEQ";
			instname[ 6] = "BIT";
			instname[ 7] = "BMI";
			instname[ 8] = "BNE";
			instname[ 9] = "BPL";
			instname[10] = "BRK";
			instname[11] = "BVC";
			instname[12] = "BVS";
			instname[13] = "CLC";
			instname[14] = "CLD";
			instname[15] = "CLI";
			instname[16] = "CLV";
			instname[17] = "CMP";
			instname[18] = "CPX";
			instname[19] = "CPY";
			instname[20] = "DEC";
			instname[21] = "DEX";
			instname[22] = "DEY";
			instname[23] = "EOR";
			instname[24] = "INC";
			instname[25] = "INX";
			instname[26] = "INY";
			instname[27] = "JMP";
			instname[28] = "JSR";
			instname[29] = "LDA";
			instname[30] = "LDX";
			instname[31] = "LDY";
			instname[32] = "LSR";
			instname[33] = "NOP";
			instname[34] = "ORA";
			instname[35] = "PHA";
			instname[36] = "PHP";
			instname[37] = "PLA";
			instname[38] = "PLP";
			instname[39] = "ROL";
			instname[40] = "ROR";
			instname[41] = "RTI";
			instname[42] = "RTS";
			instname[43] = "SBC";
			instname[44] = "SEC";
			instname[45] = "SED";
			instname[46] = "SEI";
			instname[47] = "STA";
			instname[48] = "STX";
			instname[49] = "STY";
			instname[50] = "TAX";
			instname[51] = "TAY";
			instname[52] = "TSX";
			instname[53] = "TXA";
			instname[54] = "TXS";
			instname[55] = "TYA";
		}
		
		private static function initAddrDesc():void
		{
			addrDesc = Vector.<String>([
				"Zero Page           ",
				"Relative            ",
				"Implied             ",
				"Absolute            ",
				"Accumulator         ",
				"Immediate           ",
				"Zero Page,X         ",
				"Zero Page,Y         ",
				"Absolute,X          ",
				"Absolute,Y          ",
				"Preindexed Indirect ",
				"Postindexed Indirect",
				"Indirect Absolute   "
			]);
		}
	}
}