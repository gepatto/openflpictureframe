package;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.FPS;
import openfl.display.Shader;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TimerEvent;
import openfl.events.IOErrorEvent;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.net.URLRequest;
import openfl.ui.Mouse;
import openfl.ui.Keyboard;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import openfl.Assets;
import openfl.utils.Timer;

import motion.Actuate;
import motion.easing.Cubic;

import FadeShader;
import Settings;
import StyleManager;

class Main extends Sprite {
	
	var fps:FPS;
	var bitmap:Bitmap;
	var blackScreen:BitmapData;
	var front:BitmapData;
	var back:BitmapData;
	var screenRect:Rectangle;
	var feedbackField:TextField;
	var fshader:FadeShader;
  	var settings:Settings;
	var loader:Loader;

	var tweenValue:Float = 0.0;
	var tweenDelay:Timer;
	
	var fileIndex = 0;
	var files:Array<String>=[];

	public function new () {
		
		super ();
		
		StyleManager.initialize();

		feedbackField = new TextField ();
        feedbackField.width = stage.stageWidth - 80;
        feedbackField.height = 64;
        feedbackField.y = stage.stageHeight - feedbackField.height;
       	feedbackField.defaultTextFormat = StyleManager.defaultCenteredFormat;
		feedbackField.embedFonts = true;
        feedbackField.selectable = false;
        feedbackField.multiline = true;
	
		fps = new FPS();
		
		//initialize Loaders for back and front
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		
		//initialize Reusable BitmapDataBuffers
		initBuffers();

		//
		bitmap 		= new Bitmap ( blackScreen );
		addChild(bitmap);

		settings = Settings.init();
		if(settings.loadSuccess){
			
			fps.visible = settings.showFPS;
			
			listImages(settings.path);
			if(files.length>0){
				loadImage(files[0]);
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_onKeyDown);
			stage.addEventListener(Event.RESIZE, stage_onResize);

		}else{
			trace('${settings.path} does not exists');
			feedbackField.text = '"${settings.path}" does not exists';
		}

		tweenDelay = new Timer(settings.displayTime ,1 );
		tweenDelay.addEventListener(TimerEvent.TIMER, nextImage );
		
		addChild(fps);
		addChild(feedbackField);

		Mouse.hide();
	}
	
	function initBuffers(dispose:Bool=false){
		//initialize Reusable BitmapDataBuffers
		if(dispose && blackScreen!=null){
			blackScreen.dispose();
			front.dispose();
			back.dispose();
		}
		blackScreen = new BitmapData( stage.stageWidth,stage.stageHeight,true,0x000000);
		front		= new BitmapData( stage.stageWidth,stage.stageHeight,true,0x000000);
		back		= new BitmapData( stage.stageWidth,stage.stageHeight,true,0x000000);
		screenRect  = new Rectangle(0,0, stage.stageWidth,stage.stageHeight);
	}

	function stage_onResize(event:Event=null){
		trace("stage_onResize");
		// TODO: 
		// stop transition if runnning
		// stop tweenTimer 
		// dispose bitmapdata buffers and create new ones at windowsize
		// reload images
		// reload images
	}

	function listImages(directory:String = "./images/") {
		files = [];

		if (sys.FileSystem.exists(directory)) {
			for (file in sys.FileSystem.readDirectory(directory)) {
				var path = haxe.io.Path.join([directory, file]);
				// ** IGNORE SUBDIRECTORIES **
				if (!sys.FileSystem.isDirectory(path)) {
					if( ["jpg","JPG","png","PNG"].indexOf(haxe.io.Path.extension(file)) > -1 && ( file.indexOf("._") != 0) ){
						files.push(path);
					}
				}
			}

			// sort files by name
			files.sort(function(a,b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()) );

		} else {
			trace('$directory does not exists');
			feedbackField.text = '"$directory" does not exists. Press ESC to Quit';
		}

		
	}

	function nextImage(e:Event = null){

		if( fileIndex < files.length-1 ) {
			fileIndex++;
		}else {
			fileIndex = 0;
		}
		loadImage( files[ fileIndex ] );
	}

	function fitBitmapData( source:BitmapData, destination:BitmapData){
		var w = destination.width; var h = destination.height;
		var wratio:Float;
		var hratio:Float;
		switch(settings.contentFill){
			case ContentFill.FIT:
				wratio = hratio = Math.min( w / source.width,  h / source.height);
			case ContentFill.FILL:
				wratio = hratio = Math.max( w / source.width,  h / source.height);
			case ContentFill.SCALE:
				wratio = w / source.width;
				hratio = h / source.height;
		}
		var matrix:Matrix = new Matrix();
		matrix.scale(wratio, hratio);
		matrix.translate(  (w- (wratio*source.width))*.5 , (h- (hratio*source.height))*.5);

		destination.fillRect(screenRect, 0xFF000000);
		destination.draw(source,matrix,null,null,true);
	}

	function startTransition(back:BitmapData, front:BitmapData){
		tweenValue = 0.0;
		fshader = new FadeShader ();
		fshader.img1.input = back;
		fshader.img2.input = front;
		fshader.pct.value = [tweenValue];
		bitmap.shader = fshader;
		startTween();
		feedbackField.text = "";
	}	

	private function startTween(e:Event=null){
		Actuate.tween(this, (settings.transitionTime / 1000), {tweenValue:1}).ease(Cubic.easeIn).onComplete(tweenComplete).onUpdate(tweenUpdate );
	}

	private function tweenComplete(){
		tweenDelay.start();
		if(settings.showFileName) feedbackField.text = files[fileIndex];
	}

	private function tweenUpdate(){
		fshader.pct.value = [tweenValue];
		bitmap.invalidate();
	}

	private function loadImage(frontImage:String):Void
	{
		loader.load(new URLRequest(frontImage));
	}

	private function loadCompleteHandler(event:Event):Void 
	{
		back.fillRect(screenRect, 0xFF000000);
		back.draw(front);
		fitBitmapData( cast(loader.content,Bitmap).bitmapData, front);
		startTransition(back,front);
		cast(loader.content,Bitmap).bitmapData.dispose();
		loader.unload();
	}
		
	private function ioErrorHandler(event:IOErrorEvent):Void 
	{
		trace('Image load failed ${event.toString()}');
	}

	private function stage_onKeyDown (event:KeyboardEvent):Void
	{	
		#if rpi
			//trace("keyCode:" + event.keyCode);
		#end

		switch (event.keyCode) {
			case Keyboard.ESCAPE: 
				openfl.system.System.exit(0);
			case Keyboard.D: 
				trace(files);
				feedbackField.text = files.toString();
			case Keyboard.W: 
				fps.visible = !fps.visible;
			case Keyboard.F: 
				switch(settings.contentFill){
					case ContentFill.FIT:
						settings.contentFill = ContentFill.FILL;
					case ContentFill.FILL:
						settings.contentFill = ContentFill.SCALE;
					case ContentFill.SCALE:
						settings.contentFill = ContentFill.FIT;
				}
				feedbackField.text = settings.contentFill;
			case Keyboard.S: 
				settings.showFileName = !settings.showFileName;	
			case Keyboard.SPACE: 
				tweenDelay.stop();
				Actuate.stop(this,true);
				listImages(settings.path);
				loadImage(files[0]);		
		}
	}
}