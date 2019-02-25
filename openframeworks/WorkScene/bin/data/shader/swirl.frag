#define PI 3.14159


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  float effectRadius = 1.5;
  float effectAngle = 2. * PI * (iTime * 10.0);
  vec2 center = vec2(.5, .5);
  vec2 uv = fragCoord.xy / iResolution.xy - center;
  float len = length(uv * vec2(iResolution.x / iResolution.y, 1.));
  float angle = atan(uv.y, uv.x) + effectAngle * smoothstep(effectRadius, 0., len);
  float radius = length(uv);

  fragColor = texture(iChannel0, vec2(radius * cos(angle), radius * sin(angle)) + center);
}
