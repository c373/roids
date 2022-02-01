uniform float width;
uniform float height;
uniform float offsetWidth;
uniform float offsetHeight;

bool check( vec4 sample )
{
	if ( sample.r != 0 && sample.g != 0 && sample.b != 0 && sample.a != 0 )
		return true;
	else
		return false;
}

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 px )
{
	vec4 orig = Texel( tex, uv );
	vec4 sample = orig;

	//topleft
	if ( uv.x < offsetWidth * 2 && uv.y < offsetHeight * 2 )
	{
		sample = Texel( tex, vec2( uv.x + width, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
	}

	//topright
	if ( 1 - uv.x < offsetWidth * 2 && uv.y < offsetHeight * 2 )
	{
		sample = Texel( tex, vec2( uv.x - width, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
	}

	//bottomleft
	if ( uv.x < offsetWidth * 2 && 1 - uv.y < offsetHeight * 2 )
	{
		sample = Texel( tex, vec2( uv.x + width, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
	}

	//bottomright
	if ( 1 - uv.x < offsetWidth * 2 && 1 - uv.y < offsetHeight * 2 )
	{
		sample = Texel( tex, vec2( uv.x - width, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );
		if( check( sample ) )
			return color * sample;
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
	}

	//left 
	if ( uv.x < offsetWidth * 2 && uv.y > offsetHeight * 2 && 1 - uv.y > offsetHeight * 2 )
	{
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );
		if( check( sample ) )
			return color * sample;
	}

	//right 
	if ( 1 - uv.x < offsetWidth * 2 && uv.y > offsetHeight * 2 && 1 - uv.y > offsetHeight * 2 )
	{
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );
		if( check( sample ) )
			return color * sample;
	}

	//top 
	if ( uv.y < offsetHeight * 2 && uv.x > offsetWidth * 2 && 1 - uv.x > offsetWidth * 2 )
	{
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
	}
	
	//bottom 
	if ( 1 - uv.y < offsetHeight * 2 && uv.x > offsetWidth * 2 && 1 - uv.x > offsetWidth * 2 )
	{
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
	}

	return color * orig;	
}

