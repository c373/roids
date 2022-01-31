uniform float width;
uniform float height;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 px )
{
	vec4 origColor = Texel( tex, uv );
	vec4 wrapColor = Texel( tex, vec2( uv.x + 0.25, uv.y + 0.25 ) );

	if ( wrapColor.r != 0 && wrapColor.g != 0 && wrapColor.b != 0 )
		return wrapColor * color;
	else
		return origColor * color;
}
