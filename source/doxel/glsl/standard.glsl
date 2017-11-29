#version 400

#if VERTEX_SHADER
layout(location=0) in vec3 position;
layout(location=1) in vec3 normal;
layout(location=2) in vec2 uv;

out vec3 Color;
out vec2 TexCoord;

uniform vec3 LightDirection;
uniform vec3 LightColor;
uniform vec3 AmbientColor;
uniform vec3 MaterialColor;
uniform mat4 PVM;
uniform mat3 NormalMatrix;

void main()
{
  vec3 n = NormalMatrix * normal;
  vec3 ray = normalize(LightDirection);
  Color = MaterialColor * ( AmbientColor + LightColor * max(dot(ray, -n), 0.0) );
  TexCoord = uv;
  gl_Position = PVM * vec4(position, 1.0);
}
#endif

#if FRAGMENT_SHADER
in vec3 Color;
in vec2 TexCoord;
out vec4 FragColor;
uniform sampler2D Atlas;
void main()
{
  vec3 texColor = texture(Atlas, TexCoord).rgb;
  vec3 col = Color*texColor;
  FragColor = vec4(col, 1.0);
}
#endif