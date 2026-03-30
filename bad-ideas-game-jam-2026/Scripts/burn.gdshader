shader_type canvas_item;

uniform float burn_progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D burn_texture : hint_default_white;
uniform vec3 scorch_color : source_color = vec3(0.3, 0.2, 0.1);  // Brown scorched paper
uniform vec3 burn_color_middle : source_color = vec3(1.0, 0.5, 0.0);  // Orange
uniform vec3 burn_color_outer : source_color = vec3(1.0, 0.8, 0.0);  // Yellow
uniform float scorch_thickness : hint_range(0.0, 0.15) = 0.05;
uniform float burn_thickness : hint_range(0.0, 0.2) = 0.1;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);

    if (burn_progress == 0.0) {
        COLOR = original_color;
    } else {
        float noise = texture(burn_texture, UV).r;
        float threshold = burn_progress + noise * 0.3;

        // Distance from the burn edge (negative when in burned area, positive when in glow)
        float dist_to_edge = noise - threshold;

        if (noise < threshold) {
            // Fully burned - discard
            discard;
        } else if (dist_to_edge < scorch_thickness + burn_thickness) {
            // In the edge glow zone

            vec3 final_color;
            float alpha;

            // Reverse the order - scorch is closest to burned area (smallest dist_to_edge)
            if (dist_to_edge > burn_thickness) {
                // In scorch zone (closest to burned area)
				float blend = (dist_to_edge - burn_thickness) / (scorch_thickness * 0.5);
                final_color = mix(scorch_color,original_color.rgb, blend);
                alpha = 1.0;
            } else if (dist_to_edge < scorch_thickness + (burn_thickness * 0.5)) {
                // In middle zone - blend scorch to middle
                float blend = (dist_to_edge - scorch_thickness) / (burn_thickness * 0.5);
                final_color = mix(burn_color_middle, scorch_color, blend);
                alpha = 1.0;
            } else {
                // In outer zone - blend middle to outer (fades to transparent)
                float blend = (dist_to_edge - scorch_thickness - (burn_thickness * 0.5)) / (burn_thickness * 0.5);
                final_color = burn_color_outer;
                // Fade out the outer layer towards the unburned area
                alpha = 1.0 - blend;
            }

            COLOR = vec4(final_color, alpha);
        } else {
            // Normal area - show original
            COLOR = original_color;
        }
    }
}