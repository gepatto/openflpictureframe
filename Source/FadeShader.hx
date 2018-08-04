package;

import openfl.display.DisplayObjectShader;

class FadeShader extends DisplayObjectShader {
	
	@:glFragmentSource("
		
		#pragma header
		
		uniform sampler2D img1;
		uniform sampler2D img2;
		uniform float pct;
		
		vec3 transition(vec3 tex0, vec3 tex1, float t)
		{
    		return mix(tex0, tex1, t);	
		}

		void main(void) {
			
			#pragma body

			vec3 c1 = texture2D (img1, openfl_TextureCoordv).xyz;
			vec3 c2 = texture2D (img2, openfl_TextureCoordv).xyz;
			vec3 r = transition(c1,c2, pct);
			gl_FragColor = vec4(r,1);
			
		}
		
	")
	
	public function new () {
		
		super ();
		
	}
	
}