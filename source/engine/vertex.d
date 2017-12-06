import gfm.math;

struct VertexP
{
  vec3f position;
}

struct VertexPN
{
  vec3f position;
  vec3f normal;
}

struct VertexPC
{
  vec3f position;
  vec3f color;
}

struct VertexPNT
{
  vec3f position;
  vec3f normal;
  vec2f uv;
}

struct VertexPNC
{
  vec3f position;
  vec3f normal;
  vec3f color;
}