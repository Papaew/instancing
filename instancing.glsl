#pragma language glsl3
#ifdef VERTEX

uniform vec2 size;
uniform sampler2D positions;
varying vec2 id;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	id = vec2(mod(gl_InstanceID, size.x), gl_InstanceID / size.y) / (size-1);
	vec4 attrib = Texel(positions, id);
	vertex_position.xy += attrib.xy;
	return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
varying vec2 id;
uniform sampler2D colors;
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 v_color = Texel(colors, id);
	return v_color * color;
}
#endif