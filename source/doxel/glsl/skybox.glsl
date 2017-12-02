#version 400

#if VERTEX_SHADER
in vec3 position;
out vec3 texCoord;

uniform mat4 Projection;
uniform mat4 View;

void main()
{
  gl_position = Projection * View * vec4(position, 1.0);
  texCoord = position;
}
#endif

#if FRAGMENT_SHADER
in vec3 texCoord;
out vec4 color;

uniform samplerCube cubeMap;

void main()
{
  color = texture(cubeMap, textureCoords);
}
#endif