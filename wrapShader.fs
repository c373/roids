extern number screenWidth;

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	if( vertex_position.x < 100 )
	{
		vertex_position.x = screenWidth;
	}
	else if( vertex_position.x > screenWidth )
	{
		vertex_position.x = 100;
	}

	return vec4( transform_projection * vertex_position );
}