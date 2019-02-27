#version 150
#define PI 3.14159

const int number_of_targets = 56;

uniform float time;
uniform float radiusScale;
uniform vec2 resolution;
uniform sampler2DRect tex0; // gibberish text
uniform vec2 targets[number_of_targets];

in vec2 texCoordVarying;
out vec4 outputColor;

void main() {
  // normal mode
  vec2 p = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
  vec3 color = vec3(0.0);
  for(int i = 0; i < number_of_targets; i++){

    vec2 t = vec2(targets[i].x, -targets[i].y) / min(resolution.x, resolution.y) * 2.0;
    t.xy += vec2(-resolution.x, resolution.y) / min(resolution.x, resolution.y);

    float v = 0.02 * radiusScale / length(p - t);
    vec3 c = vec3(smoothstep(0.2, 1.0, v));
    color += c;
  }
  vec4 text = texture(tex0, texCoordVarying);
  outputColor = vec4(text.rgb, clamp(color, 0., 0.5));
}
