uniform float width;
uniform float height;
uniform float offsetWidth;
uniform float offsetHeight;
uniform float dblOffsetWidth;
uniform float dblOffsetHeight;

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
	
	// early exit if the pixel is within the non visible area of the buffer
	if ( uv.x < offsetWidth || 1 - uv.x < offsetWidth || uv.y < offsetHeight || 1 - uv.y < offsetHeight )
		return color * orig;

	vec4 sample;

	// handle a pixel in the topleft area
	if ( uv.x < dblOffsetWidth && uv.y < dblOffsetHeight )
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
	if ( 1 - uv.x < dblOffsetWidth && uv.y < dblOffsetHeight )
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
	if ( uv.x < dblOffsetWidth && 1 - uv.y < dblOffsetHeight )
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
	if ( 1 - uv.x < dblOffsetWidth && 1 - uv.y < dblOffsetHeight )
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
	if ( uv.x < dblOffsetWidth && uv.y > dblOffsetHeight && 1 - uv.y > dblOffsetHeight )
	{
		// sample past the right limit
		sample = Texel( tex, vec2( uv.x + width, uv.y ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixel in the right area
	if ( 1 - uv.x < dblOffsetWidth && uv.y > dblOffsetHeight && 1 - uv.y > dblOffsetHeight )
	{
		// sample past the left limit
		sample = Texel( tex, vec2( uv.x - width, uv.y ) );
		if( check( sample ) )
			return color * sample;
	}

	// handle a pixel in the top area 
	if ( uv.y < dblOffsetHeight && uv.x > dblOffsetWidth && 1 - uv.x > dblOffsetWidth )
	{
		// sample past the bottom limit
		sample = Texel( tex, vec2( uv.x, uv.y + height ) );
		if( check( sample ) )
			return color * sample;
	}
	
	// handle a pixel in the bottom area 
	if ( 1 - uv.y < dblOffsetHeight && uv.x > dblOffsetWidth && 1 - uv.x > dblOffsetWidth )
	{
		// sample past the top limit
		sample = Texel( tex, vec2( uv.x, uv.y - height ) );
		if( check( sample ) )
			return color * sample;
	}

	// if this pixel is not within any of the buffer areas return the original color
	return color * orig;
}

