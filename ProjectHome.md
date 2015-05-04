# vNES actionscript 3.0 port #
### AS3NES 는 Adobe 플래시 플랫폼을 위한 NES 에뮬레이터 라이브러리 입니다. ###

이 프로젝트의 목적은 에뮬레이터 환경을 만들기 위한 라이브러리 제작입니다. 실행을 위한 롬파일 로더, 키 설정, GUI 등은 이 프로젝의 범위안에 있지 않습니다.

NES에 관한 설명은 wikipedia참조에 상세히 나와있습니다. 하드웨어에 관한 문의, 롬파일에 관한 문의는 받지 않습니다.

본 프로젝트는 vNES 프로젝트의 2.11버전을 기반으로 포팅되었습니다만,
사운드출력과 이미지 출력을 AS3에 맞게끔 변경하였고, 핵심 코드( CPU , PPU , APU 에뮬레이팅)를 제외하고 다른부분은 AS3에 맞게끔 재구성되었습니다. 따라서 vNES와 똑같이 동작하지 않고, 또한 동작에 관한 보증을 하지 않습니다.

## Sample code on FLEX ##
```
<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" creationComplete="init()">
<mx:Script>
	<![CDATA[
	import com.mobswing.model.BootInfo;
	import com.mobswing.model.Joystick;
	import com.mobswing.model.Cartridge;
	import com.mobswing.view.As3nes;
	
	private var loader:URLLoader;
	private var as3nes:com.mobswing.view.As3nes;
	
	private function init():void
	{
		as3nes = new As3nes();//가상머신을 만든다
		this.uic.addChild(as3nes);
		
		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, onLoaded);
		loader.load(new URLRequest('Super Mario Bros.nes'));//롬파일을 불러온다
	}
	
	private function onLoaded(event:Event):void
	{
		var j1:Joystick = new Joystick(
			Keyboard.UP,	Keyboard.DOWN,	Keyboard.LEFT,	Keyboard.RIGHT,
			Keyboard.ENTER,	Keyboard.SHIFT,	88,				90
		);
		var option:BootInfo = new BootInfo(j1);	//부팅 옵션을 설정한다.
		as3nes.startEmulation(new Cartridge(loader.data as ByteArray), option);//에뮬레이팅을 시작한다.
	}
	]]>
</mx:Script>
<mx:UIComponent id="uic" width="256" height="240" horizontalCenter="0" verticalCenter="0"/>
</mx:Application>
```

## Contact me ##
**buvlet@gmail.com** or **buzzler@hotmail.com** or **buzzler@buzzler.pe.kr**