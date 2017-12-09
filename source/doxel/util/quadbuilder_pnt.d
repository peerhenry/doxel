import gfm.opengl, gfm.math;

import engine;

import sides;

// todo: make generic
VertexPNT[4] generateQuad(Side side, vec3f center, vec2i atlasIndex)
{
  VertexPNT[4] output;
  vec2f[4] uvs = [
    vec2f((32.0*atlasIndex.x + 0.5)/512, (32.0*atlasIndex.y + 31.5)/512)
    , vec2f((32.0*atlasIndex.x + 0.5)/512, (32.0*atlasIndex.y + 0.5)/512)
    , vec2f((32.0*atlasIndex.x + 31.5)/512, (32.0*atlasIndex.y + 31.5)/512)
    , vec2f((32.0*atlasIndex.x + 31.5)/512, (32.0*atlasIndex.y + 0.5)/512)
  ];
  final switch(side)
  {
    case Side.Top:
      vec3f normal = vec3f(0, 0, 1);
      output[0] = VertexPNT(center + vec3f(-0.5, -0.5, 0), normal, uvs[0]);
      output[1] = VertexPNT(center + vec3f(-0.5, 0.5, 0), normal, uvs[1]);
      output[2] = VertexPNT(center + vec3f(0.5, -0.5, 0), normal, uvs[2]);
      output[3] = VertexPNT(center + vec3f(0.5, 0.5, 0), normal, uvs[3]);
      break;
    case Side.Bottom:
      vec3f normal = vec3f(0, 0, -1);
      output[0] = VertexPNT(center + vec3f(0.5, -0.5, 0), normal, uvs[0]);
      output[1] = VertexPNT(center + vec3f(0.5, 0.5, 0), normal, uvs[1]);
      output[2] = VertexPNT(center + vec3f(-0.5, -0.5, 0), normal, uvs[2]);
      output[3] = VertexPNT(center + vec3f(-0.5, 0.5, 0), normal, uvs[3]);
      break;
    case Side.North:
      vec3f normal = vec3f(0, 1, 0);
      output[0] = VertexPNT(center + vec3f(0.5, 0, -0.5), normal, uvs[0]);
      output[1] = VertexPNT(center + vec3f(0.5, 0, 0.5), normal, uvs[1]);
      output[2] = VertexPNT(center + vec3f(-0.5, 0, -0.5), normal, uvs[2]);
      output[3] = VertexPNT(center + vec3f(-0.5, 0, 0.5), normal, uvs[3]);
      break;
    case Side.South:
      vec3f normal = vec3f(0, -1, 0);
      output[0] = VertexPNT(center + vec3f(-0.5, 0, -0.5), normal, uvs[0]);
      output[1] = VertexPNT(center + vec3f(-0.5, 0, 0.5), normal, uvs[1]);
      output[2] = VertexPNT(center + vec3f(0.5, 0, -0.5), normal, uvs[2]);
      output[3] = VertexPNT(center + vec3f(0.5, 0, 0.5), normal, uvs[3]);
      break;
    case Side.East:
      vec3f normal = vec3f(1, 0, 0);
      output[0] = VertexPNT(center + vec3f(0, -0.5, -0.5), normal, uvs[0]);
      output[1] = VertexPNT(center + vec3f(0, -0.5, 0.5), normal, uvs[1]);
      output[2] = VertexPNT(center + vec3f(0, 0.5, -0.5), normal, uvs[2]);
      output[3] = VertexPNT(center + vec3f(0, 0.5, 0.5), normal, uvs[3]);
      break;
    case Side.West:
      vec3f normal = vec3f(-1, 0, 0);
      output[0] = VertexPNT(center + vec3f(0, 0.5, -0.5), normal, uvs[0]);
      output[1] = VertexPNT(center + vec3f(0, 0.5, 0.5), normal, uvs[1]);
      output[2] = VertexPNT(center + vec3f(0, -0.5, -0.5), normal, uvs[2]);
      output[3] = VertexPNT(center + vec3f(0, -0.5, 0.5), normal, uvs[3]);
      break;
  }
  return output;
}

VertexP[4] generateQuadPositions(Side side, vec3f center, float size)
{
  VertexP[4] output;
  final switch(side)
  {
    case Side.Top:
      output[0] = VertexP(center + size*vec3f(-0.5, -0.5, 0));
      output[1] = VertexP(center + size*vec3f(-0.5, 0.5, 0));
      output[2] = VertexP(center + size*vec3f(0.5, -0.5, 0));
      output[3] = VertexP(center + size*vec3f(0.5, 0.5, 0));
      break;
    case Side.Bottom:
      output[0] = VertexP(center + size*vec3f(0.5, -0.5, 0));
      output[1] = VertexP(center + size*vec3f(0.5, 0.5, 0));
      output[2] = VertexP(center + size*vec3f(-0.5, -0.5, 0));
      output[3] = VertexP(center + size*vec3f(-0.5, 0.5, 0));
      break;
    case Side.North:
      output[0] = VertexP(center + size*vec3f(0.5, 0, -0.5));
      output[1] = VertexP(center + size*vec3f(0.5, 0, 0.5));
      output[2] = VertexP(center + size*vec3f(-0.5, 0, -0.5));
      output[3] = VertexP(center + size*vec3f(-0.5, 0, 0.5));
      break;
    case Side.South:
      output[0] = VertexP(center + size*vec3f(-0.5, 0, -0.5));
      output[1] = VertexP(center + size*vec3f(-0.5, 0, 0.5));
      output[2] = VertexP(center + size*vec3f(0.5, 0, -0.5));
      output[3] = VertexP(center + size*vec3f(0.5, 0, 0.5));
      break;
    case Side.East:
      output[0] = VertexP(center + size*vec3f(0, -0.5, -0.5));
      output[1] = VertexP(center + size*vec3f(0, -0.5, 0.5));
      output[2] = VertexP(center + size*vec3f(0, 0.5, -0.5));
      output[3] = VertexP(center + size*vec3f(0, 0.5, 0.5));
      break;
    case Side.West:
      output[0] = VertexP(center + size*vec3f(0, 0.5, -0.5));
      output[1] = VertexP(center + size*vec3f(0, 0.5, 0.5));
      output[2] = VertexP(center + size*vec3f(0, -0.5, -0.5));
      output[3] = VertexP(center + size*vec3f(0, -0.5, 0.5));
      break;
  }
  return output;
}