#version 400

#if VERTEX_SHADER
layout(location=0) in vec3 position;

uniform mat4 PVM;

void main()
{
  gl_Position = PVM * vec4(position, 1.0);
}
#endif

#if FRAGMENT_SHADER
in vec3 Color;
out vec4 FragColor;
void main()
{
  FragColor = vec4(0.5,0.6,0.95, 0.5);
}
#endif