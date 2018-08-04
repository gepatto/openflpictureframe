package;

import openfl.utils.Endian;
import haxe.Json;
import openfl.Assets;

@:enum abstract ContentFill(String){
	var FILL   = "fill";
	var FIT    = "fit";
	var SCALE  = "scale";
}

class Settings{

    public static var instance(default, null):Settings = new Settings();

    static var config:Dynamic;

    public var path:String = "./images/";
    public var displayTime:UInt = 5000;
    public var transitionTime:UInt = 1000;
    public var showFPS:Bool = false;
    public var showFileName:Bool = false;
    public var contentFill:ContentFill = ContentFill.FILL;
    
    public var loadSuccess:Bool = false;

    private function new () {}

    public static function init():Settings{
        return instance.load();
    } 
    
    public function load():Settings {
        
        if(sys.FileSystem.exists("./config.json")){
            config = Json.parse (sys.io.File.getContent("./config.json"));
            if( Reflect.hasField(config, "showFPS")) showFPS = cast(config.showFPS,Bool);
            if( Reflect.hasField(config, "showFileName")) showFileName = cast(config.showFileName,Bool);
            if( Reflect.hasField(config, "path")) path = cast(config.path,String);
            if( Reflect.hasField(config, "displayTime" )) displayTime = cast(config.displayTime, UInt);
            if( Reflect.hasField(config, "transitionTime")) transitionTime = cast(config.transitionTime, UInt);
            if( Reflect.hasField(config, "contentFill")) contentFill = cast(config.contentFill.toLowerCase(), ContentFill);
        }

        #if !html5
        var args = Sys.args();
        if(args.length > 0){
            for( arg in args){
                var argArray:Array<String> = arg.split("=");
                if(argArray.length > 1){
                    if( Type.getInstanceFields(Settings).indexOf(argArray[0])!=-1){
                        Reflect.setField(this,argArray[0],argArray[1].toLowerCase());
                    }else{
                        trace( 'no ${argArray[0]} field in settings');
                    }
                }					
            }
        }
        #end

        loadSuccess = sys.FileSystem.exists(path);
        return instance;
    }

}