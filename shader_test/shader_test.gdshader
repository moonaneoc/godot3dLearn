shader_type canvas_item;

void fragment() {
	// Place fragment code here.
	COLOR.rgb = vec3(UV.x, 1, 0);
//	COLOR.rgb = vec3(mix(1,0,0.5) * UV.x *4.0, 1, 0);
//	COLOR.rgb = vec3(1, 1, 0);
	
}
