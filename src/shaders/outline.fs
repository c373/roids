vec4 resultCol;
vec4 textureCol;
#define outline_width 0.001f

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	number alpha = 8 * texture2D( texture, texturePos ).a;
    alpha -= texture2D( texture, texturePos + vec2( outline_width, 0.0f ) ).a;
    alpha -= texture2D( texture, texturePos + vec2( -outline_width, 0.0f ) ).a;
    alpha -= texture2D( texture, texturePos + vec2( 0.0f, outline_width ) ).a;
    alpha -= texture2D( texture, texturePos + vec2( 0.0f, -outline_width ) ).a;
	alpha -= texture2D( texture, texturePos + vec2( -outline_width, -outline_width ) ).a;
    alpha -= texture2D( texture, texturePos + vec2( outline_width, outline_width ) ).a;
    alpha -= texture2D( texture, texturePos + vec2( -outline_width, outline_width ) ).a;
    alpha -= texture2D( texture, texturePos + vec2( outline_width, -outline_width ) ).a;

	// calculate resulting color
    return vec4( 1.0f, 1.0f, 1.0f, alpha );
}
