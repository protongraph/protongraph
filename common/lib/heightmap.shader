shader_type spatial;

uniform sampler2D heightmap;
uniform float texture_size = 128.0;
uniform float scale = 1.0;
uniform float offset = 0.0;
uniform bool show_color = true;


vec3 getNormal(vec2 uv) {
	float texel_size = 1.0 / texture_size;
    float u = texture(heightmap, uv + texel_size * vec2(0.0, -1.0)).r;
    float r = texture(heightmap, uv + texel_size * vec2(-1.0, 0.0)).r;
    float l = texture(heightmap, uv + texel_size * vec2(1.0, 0.0)).r;
    float d = texture(heightmap, uv + texel_size * vec2(0.0, 1.0)).r;

    vec3 n;
    n.z = (u - d) * scale;
    n.x = (r - l) * scale;
    n.y = 1.0;
    return normalize(n);
}


void vertex() {
	float half_pixel = 0.5 / texture_size;
	vec2 uv = UV + vec2(half_pixel);
	float height = texture(heightmap, uv).r;
	VERTEX.y += height * scale + offset;
	NORMAL = getNormal(uv);
	COLOR = vec4(height);
}

void fragment() {
	if (show_color) {
		ALBEDO = COLOR.rgb;
	}
}