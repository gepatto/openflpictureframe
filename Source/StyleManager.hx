package;

import openfl.text.Font;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.Assets;

class StyleManager {
 
    public static var instance(default, null):StyleManager = new StyleManager();

    static var squada:Font;
    
    public static var defaultFormat:TextFormat;
    public static var defaultCenteredFormat:TextFormat;

    function new(){}

    public static function initialize(){
        squada = Assets.getFont ("fonts/Squada_One.ttf");
        defaultFormat = new TextFormat (squada.fontName, 32, 0xFFFFFF);
        defaultFormat.align = TextFormatAlign.LEFT;
        defaultCenteredFormat = new TextFormat (squada.fontName, 32, 0xFFFFFF);
        defaultCenteredFormat.align = TextFormatAlign.CENTER;
    
    }
}