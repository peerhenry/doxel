#version 400

#if VERTEX_SHADER
layout(location=0) in vec3 position;

out vec3 VertexColor;

uniform mat4 PVM;
uniform vec3 Color;

void main()
{
  VertexColor = Color;
  gl_Position = PVM * vec4(position, 1.0);
}
#endif

#if FRAGMENT_SHADER
in vec3 VertexColor;
out vec4 FragColor;
void main()
{
  FragColor = vec4(VertexColor, 1.0);
}
#endif