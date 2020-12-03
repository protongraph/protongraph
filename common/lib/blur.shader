shader_type canvas_item;

const float tau = 6.28318530718;

uniform sampler2D map;
uniform float texture_size;
uniform float directions = 16.0;
uniform float quality = 3.0;
uniform float size = 8.0;


void fragment() {
	vec2 radius = size / vec2(texture_size);
	vec4 color = texture(map, UV);

	// Blur calculations
	for (float d = 0.0; d < tau; d += tau / directions) {
		for (float i = 1.0 / quality; i <= 1.0; i += 1.0 / quality){
			color += texture(map, UV + vec2(cos(d), sin(d)) * radius * i);
		}
	}
	
	// Output to screen
	color /= quality * directions - 15.0;
	COLOR = color;
}