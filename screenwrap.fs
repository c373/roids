uniform float width;
uniform float height;
uniform float offsetWidth;
uniform float offsetHeight;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 px )
{
	vec4 orig = Texel( tex, uv );
	vec4 sample;

	//left wrapzone
	if ( uv.x < offsetWidth * 2  )
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );

	//right wrapzone
	if ( 1 - uv.x < offsetWidth * 2  )
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );

	//top wrapzone
	if ( uv.y < offsetHeight * 2  )
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
	
	//bottom wrapzone
	if ( 1 - uv.y < offsetHeight * 2  )
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );

	if (sample.r != 0 && sample.g != 0 && sample.b != 0 && sample.a != 0 )
		return color * sample;
	else
		return color * orig;
}

bool check( vec4 sample )
{
	if (sample.r != 0 && sample.g != 0 && sample.b != 0 && sample.a != 0 )
		return false;
	else
		return true;
}
