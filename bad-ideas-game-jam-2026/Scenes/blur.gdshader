shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float blur_strength : hint_range(0.0, 10.0) = 5.0;
uniform float blur_radius : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    vec2 center = vec2(0.5);
    float distance_from_center = length(UV - center);
    
    // Smooth vignette
    float vignette = smoothstep(0.0, blur_radius, distance_from_center);
    
    // Blur amount
    float blur_amount = vignette * blur_strength * 0.001;
    
    // Simple directional blur samples
    vec3 color = texture(screen_texture, UV).rgb;
    vec2 blur_dir = normalize(UV - center);
    
    color += texture(screen_texture, UV + blur_dir * blur_amount).rgb;
    color += texture(screen_texture, UV + blur_dir * blur_amount * 2.0).rgb;
    color += texture(screen_texture, UV - blur_dir * blur_amount).rgb;
    color += texture(screen_texture, UV - blur_dir * blur_amount * 2.0).rgb;
    
    color /= 5.0;
    
    COLOR = vec4(color, 1.0);
}