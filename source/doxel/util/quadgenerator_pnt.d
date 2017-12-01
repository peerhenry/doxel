import gfm.math;

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