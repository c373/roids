uniform float width;
uniform float height;
uniform float offsetWidth;
uniform float offsetHeight;

// returns true if the sample pixel is fully white
bool check( vec4 sample )
{
	if ( sample.r == 1 && sample.g == 1 && sample.b == 1 && sample.a == 1 )
		return true;
	else
		return false;
}

vec4 effect( vec4 color, Image tex, vec2 uv, vec2 px )
{
	// the original pixel
	vec4 orig = Texel( tex, uv );
	vec4 sample;

	// handle a pixel in the topleft area
	if ( uv.x < offsetWidth && uv.y < offsetHeight )
	{
		// sample past the bottom right corner
		sample = Texel( tex, vec2( uv.x + width, uv.y + height ) );
		if( check( sample ) )
			return color * sample;

		// sample past the right limit
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );
		if( check( sample ) )
			return color * sample;

		// sample past the bottom limit
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixel in the topright area
	if ( 1 - uv.x < offsetWidth && uv.y < offsetHeight )
	{
		// sample past the bottom left corner
		sample = Texel( tex, vec2( uv.x - width, uv.y + height ) );
		if( check( sample ) )
			return color * sample;

		// sample past the left limit
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );
		if( check( sample ) )
			return color * sample;

		// sample past the bottom limit
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixel in the bottomleft area
	if ( uv.x < offsetWidth && 1 - uv.y < offsetHeight )
	{
		// sample past the top right corner
		sample = Texel( tex, vec2( uv.x + width, uv.y - height ) );
		if( check( sample ) )
			return color * sample;

		// sample past the right limit
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );
		if( check( sample ) )
			return color * sample;

		// sample past the top limit
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixel in the bottomright area
	if ( 1 - uv.x < offsetWidth && 1 - uv.y < offsetHeight )
	{
		// sample past the top left corner
		sample = Texel( tex, vec2( uv.x - width, uv.y - height ) );
		if( check( sample ) )
			return color * sample;

		// sample past the left limit
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );
		if( check( sample ) )
			return color * sample;

		// sample past the top limit
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixle in the left area
	if ( uv.x < offsetWidth && uv.y > offsetHeight && 1 - uv.y > offsetHeight )
	{
		// sample past the right limit
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixel in the right area
	if ( 1 - uv.x < offsetWidth && uv.y > offsetHeight && 1 - uv.y > offsetHeight )
	{
		// sample past the left limit
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixel in the top area 
	if ( uv.y < offsetHeight && uv.x > offsetWidth && 1 - uv.x > offsetWidth )
	{
		// sample past the bottom limit
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
	}
	
	// handle a pixel in the bottom area 
	if ( 1 - uv.y < offsetHeight && uv.x > offsetWidth && 1 - uv.x > offsetWidth )
	{
		// sample past the top limit
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
	}

	// if this pixel is not within any of the buffer areas return the original color
	return color * orig;	
}

