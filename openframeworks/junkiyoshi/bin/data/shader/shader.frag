#version 150
#define PI 3.14159

const int number_of_targets = 180;

uniform float time;
uniform vec2 resolution;
uniform sampler2DRect tex0; // gibberish text
uniform sampler2DRect screen; // still screen
uniform vec2 targets[number_of_targets];

in vec2 texCoordVarying;
out vec4 outputColor;

vec4 swirl(sampler2DRect tex, vec2 uv, float time)
{
  vec2 size = vec2(resolution.x, resolution.y);

  vec2 center = vec2(size.x * 0.5, size.y * 0.5) / vec2(0.002);

  float radius = time * max(size.x,size.y) / 0.002;
  float angle = time * 2.0;

  vec2 texSize = vec2(size.x, size.y);
  vec2 tc = uv * texSize;
  tc -= center;
  float dist = length(tc);
  if (dist < radius)
  {
    float percent = (radius - dist) / radius;
    float theta = percent * percent * angle * 8.0;
    float s = sin(theta);
    float c = cos(theta);
    tc = vec2(dot(tc, vec2(c, -s)), dot(tc, vec2(s, c)));
  }
  tc += center;
  vec3 color = texture(tex, tc / texSize).rgb;
  return vec4(color, 1.0);
}

void main() {
  // normal mode
  vec2 p = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
  vec3 color = vec3(0.0);
  for(int i = 0; i < number_of_targets; i++){

    vec2 t = vec2(targets[i].x, -targets[i].y) / min(resolution.x, resolution.y) * 2.0;
    t.xy += vec2(-resolution.x, resolution.y) / min(resolution.x, resolution.y);

    float v = 0.02 / length(p - t);
    vec3 c = vec3(smoothstep(0.1, 1.0, v));
    color += c;
  }
  vec4 text = texture(tex0, texCoordVarying);

  // swirl mode

  outputColor = vec4(text.rgb, color.r);
}
