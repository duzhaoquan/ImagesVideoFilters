
precision highp float;
uniform sampler2D Texture;
varying highp vec2 TextureCoordsVarying;

void main() {
    vec2 uv = TextureCoordsVarying.xy;
    float y;
    if (uv.y >= 0.0 && uv.y <= 0.33) {
        y = uv.y + 0.33;
    }else if (uv.y > 0.66 && uv.y <= 1.0){
        y = uv.y - 0.33;
    }else{
        y = uv.y;
    }
    gl_FragColor = texture2D(Texture, vec2(uv.x, y));
}
