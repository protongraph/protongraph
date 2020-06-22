shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_lambert,specular_schlick_ggx;

uniform sampler2D albedo: hint_albedo;
uniform sampler2D heightmap: hint_albedo;
uniform sampler2D normalmap: hint_normal;

uniform float height = 64.0;
uniform float offset = 0.0;
uniform float normal_detail: hint_range(0,1) = 0.2;
uniform float normal_depth: hint_range(0,2) = 1.0;
uniform float slope_start : hint_range(0,1) = 0.02;
uniform float rock_start  : hint_range(0,1) = 0.20;
uniform float rock_blend  : hint_range(0,1) = 0.35;

uniform vec4 base_color  : hint_color = vec4(0.50, 0.45, 0.30, 1.00);
uniform bool show_colors = true;
uniform vec4 grass_color : hint_color = vec4(0.32, 0.50, 0.30, 1.00);
uniform vec4 slope_color : hint_color = vec4(0.40, 0.50, 0.32, 0.25);
uniform vec4 rock_color  : hint_color = vec4(0.60, 0.60, 0.45, 0.75);

uniform vec2 uv1_scale = vec2(1.0, 1.0);

varying float slope;

vec4 lerp(vec4 a, vec4 b, float t) {
	return mix(a, b, clamp(t * b.a, 0.0, 1.0));
}

float get_height(sampler2D t, vec2 uv) {
	return texture(t, uv).x * height;
}

vec3 get_normal(sampler2D t, vec2 uv) {
	vec2 o = vec2(normal_detail * 0.0005, 0.0);
	return normalize(vec3(
		(get_height(t, uv-o.xy) - get_height(t, uv+o.xy)),
		(get_height(t, uv-o.yx) - get_height(t, uv+o.yx)),
		(2.0 - normal_depth) * 0.1
	)) * 0.5 + 0.5;
}

void vertex() {
	
	vec2 uv = UV;
	UV = UV * uv1_scale;
	
	// get height value from heightmap, then mutliply and offset
	VERTEX.y = get_height(heightmap, uv) + offset;
	// calculate normal from heightmap
	NORMAL = get_normal(heightmap, uv).xzy * 2.0 - 1.0;
	
	// get data from normalmap texture
//	vec4 data = texture(normalmap, UV).rgba;
	// get height value from normalmap alpha channel
//	VERTEX.y = data.a * height + offset;
	// get NORMAL from rgb of normalmap and unpack for Godot
//	NORMAL = (data.xzy * 2.0 - 1.0);
	
	// calulate the slope for use in fragment shader
	slope = 1.0 - NORMAL.y;
	
	// calculate TANGENT and BINORMAL from NORMAL
	TANGENT = normalize(vec3(abs(NORMAL.y) + abs(NORMAL.z), 0.0, -abs(NORMAL.x)));
	BINORMAL = normalize(vec3(0.0, -abs(NORMAL.x) - abs(NORMAL.z), abs(NORMAL.y)));
	
	// cancel out NORMAL when using NORMALMAP in fragment shader
//	NORMAL = vec3(0, 1, 0);
}

void fragment() {
	
	vec4 c = base_color;
	if(show_colors) {
		c = grass_color;
		c = lerp(c, slope_color, slope / slope_start);
		c = lerp(c, rock_color, (slope - rock_start) * (1.0 / (rock_blend - rock_start)));
	}
	ALBEDO = c.rgb * (texture(albedo, UV).rgb + c.a);
	
	// apply normalmap
//	NORMALMAP = texture(normalmap, UV).xyz;
//	NORMALMAP_DEPTH = 1.0;
	
	// hard code PBR values
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}




