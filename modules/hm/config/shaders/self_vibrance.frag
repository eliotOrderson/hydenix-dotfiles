#version 300 es
// Hyprland 0.5x links this fragment shader against a GLSL ES 3.00 vertex shader, so the
// file must declare the same version; otherwise linking fails with
// "all shaders must use same shading language version" and Hyprland drops the shader.
// ES 3.00 syntax: in/out/texture()/fragColor instead of varying/texture2D/gl_FragColor.
//
// Tuning: edit the #define block below, then re-apply with `hyprctl reload`
// (or press Mod+Shift+C twice).
//   VIBRANCE_INTENSITY        0.0 = off, 0.2 ~= the previous uniform 1.1 boost, 0.3 default, 0.5+ strong
//   VIBRANCE_SKIN_PROTECTION  0.0 = no protection, 1.0 = strongest damping of skin-tone oversaturation
//   VIBRANCE_CONTRAST         1.0 = leave contrast untouched

precision highp float;

#ifndef VIBRANCE_INTENSITY
#define VIBRANCE_INTENSITY 0.3
#endif
#ifndef VIBRANCE_SKIN_PROTECTION
#define VIBRANCE_SKIN_PROTECTION 0.75
#endif
#ifndef VIBRANCE_CONTRAST
#define VIBRANCE_CONTRAST 1.05
#endif

in vec2 v_texcoord;
out vec4 fragColor;

uniform sampler2D tex;

const float VIBRANCE = VIBRANCE_INTENSITY;
const float SKIN_PROTECTION = VIBRANCE_SKIN_PROTECTION;
const float CONTRAST = VIBRANCE_CONTRAST;

float lumaOf(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float saturationOf(vec3 c) {
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    return mx <= 0.0 ? 0.0 : (mx - mn) / mx;
}

// Crude skin-tone test: R > G > B and inside the usual skin range.
float skinToneOf(vec3 c) {
    float order = (c.r > c.g && c.g > c.b) ? 1.0 : 0.0;
    float range = (c.r >= 0.35 && c.r <= 0.90 && c.g >= 0.18 && c.g <= 0.75 && c.b >= 0.08 && c.b <= 0.55) ? 1.0 : 0.0;
    return order * range;
}

void main() {
    vec4 pix = texture(tex, v_texcoord);
    vec3 color = pix.rgb;

    // Contrast around mid grey.
    color = (color - 0.5) * CONTRAST + 0.5;

    // Vibrance: boost muted colours more than saturated ones, and damp skin tones.
    float sat = saturationOf(color);
    float amount = VIBRANCE * (1.0 - sat);
    amount *= 1.0 - SKIN_PROTECTION * skinToneOf(color);
    color = mix(vec3(lumaOf(color)), color, 1.0 + amount);

    fragColor = vec4(clamp(color, 0.0, 1.0), pix.a);
}
