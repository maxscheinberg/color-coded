shader_type canvas_item;
uniform bool grayscale_enabled = true;

void fragment() {
    vec4 tex = texture(TEXTURE, UV) * COLOR;
    if (grayscale_enabled) {
        float gray = length(tex.rgb) * 0.5;
        tex.rgb = vec3(gray);
    }
    COLOR = tex;
}