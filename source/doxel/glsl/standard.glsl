#version 400

#if VERTEX_SHADER
layout(location=0) in vec3 position;
layout(location=1) in vec3 normal;

out vec3 Color;

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
  gl_Position = PVM * vec4(position, 1.0);
}
#endif

#if FRAGMENT_SHADER
in vec3 Color;
out vec4 FragColor;
void main()
{
  FragColor = vec4(Color,1.0);
}
#endif