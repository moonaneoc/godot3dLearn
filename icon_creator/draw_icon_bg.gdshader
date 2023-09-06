shader_type canvas_item;

uniform vec4 center_color: source_color;
uniform vec4 edge_color: source_color;

void fragment() {
	float weight = pow(UV.x - 0.5, 2) + pow(UV.y - 0.5, 2);
	vec4 ret = vec4(mix(center_color.x, edge_color.x, weight), mix(center_color.y, edge_color.y, weight), mix(center_color.z, edge_color.z, weight), min(COLOR.a, center_color.a));
	COLOR.rgba = ret;
}
