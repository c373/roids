extern int worldWidth;
extern int worldHeight;
varying vec4 vpos;

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	if ( vpos.x < 100 || vpos.x > worldWidth )
	{

	}

	vpos = vertex_position;

	return vec4( transform_projection * vpos );
}