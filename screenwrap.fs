extern number worldWidth;
extern number worldHeight;

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 px )
{
	return Texel( tex, uv );
	vec4 c = Texel( tex, vec2( uv.x + 0.25, uv.y + 0.25 ) );

	if ( c.r != 0 && c.g != 0 && c.b != 0 )
	{
		return c;
	}
	else
	{
		return Texel( tex, uv );
	}
}
