shader_type canvas_item;

uniform sampler2D map;
uniform float mesh_size;
uniform float texture_size;
uniform float scale;
uniform float threshold;
uniform float erosion_rate;
uniform bool debug;


float get_height(vec2 uv) {
	return texture(map, uv).r * scale;
}

float sign(float value) {
	if (value >= 0.0) {
		return 1.0;
	}
	return -1.0;
}


vec2 get_max_slope_dir(vec2 uv) {
	vec2 dir = vec2(0.0);
	float max_diff = 0.0;
	float height = get_height(uv);
	float its = 1.0 / texture_size;

	for (int i = 0; i < 4; i++) {
		float x = (i % 2 == 0) ? 1.0 : -1.0;
		
		for (int j = 0; j < 4; j++) {
			float y = (j % 2 == 0) ? 1.0 : -1.0;
			
			float nh = get_height(vec2(uv.x + x * its, uv.y + y * its));
			float diff = sign(height - nh);
			if (diff > max_diff) {
				max_diff = diff;
				dir.x = x * its;
				dir.y = y * its;
			}
		}
	}
	return dir;
}

void fragment() {
	float height = get_height(UV);
	vec2 slope_dir = get_max_slope_dir(UV);
	float nh = get_height(UV + slope_dir);
	float diff = height - nh;
	float cell_size = mesh_size / texture_size;
	float slope = atan(diff / cell_size);
	float amount = diff * erosion_rate;// * slope;
	COLOR = vec4((height - amount) / scale);

	if (debug) {
		COLOR = vec4(texture(map, UV).r);
	}
}
