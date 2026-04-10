precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pix = texture2D(tex, v_texcoord);
    
    // 1. 增加对比度
    pix.rgb = (pix.rgb - 0.5) * 1.05 + 0.5;

    // 2. 增加饱和度 (Vibrance)
    // 修复了这里的嵌套括号问题
    float max_val = max(pix.r, max(pix.g, pix.b));
    float min_val = min(pix.r, min(pix.g, pix.b)); 
    
    float luma = dot(pix.rgb, vec3(0.2126, 0.7152, 0.0722));
    pix.rgb = mix(vec3(luma), pix.rgb, 1.1);

    gl_FragColor = pix;
}
