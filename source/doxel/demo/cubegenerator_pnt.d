import gfm.opengl, gfm.math;

import engine;

import quadgenerator_pnt, blocks, sides;

class CubeGenerator
{
  OpenGL gl;
  VertexSpecification!VertexPNT spec;
  ModelSetter setter;

  this(OpenGL gl, VertexSpecification!VertexPNT spec, ModelSetter modelSetter)
  {
    this.gl = gl;
    this.spec = spec;
    this.setter = modelSetter;
  }

  private vec2i[6] getFacesij(Block block)
  {
    vec2i topij, bottomij, northij, southij, westij, eastij;
    final switch(block)
    {
      case Block.GRASS:
        topij = vec2i(0,0);
        bottomij = vec2i(2,0);
        northij = southij = westij = eastij = vec2i(3, 0);
        break;
      case Block.DIRT:
        topij = northij = southij = westij = eastij = bottomij = vec2i(2,0);
        break;
      case Block.STONE:
        topij = northij = southij = westij = eastij = bottomij = vec2i(1,0);
        break;
      case Block.SAND:
        topij = northij = southij = westij = eastij = bottomij = vec2i(2,1);
        break;
      case Block.EMPTY:
        topij = northij = southij = westij = eastij = bottomij = vec2i(8,8);
        break;
    }
    return [topij, bottomij, northij, southij, eastij, westij];
  }

  Model!VertexPNT generateCube(vec3f position, Block block)
  {
    vec2i[6] facesij = getFacesij(block);
    VertexPNT[] vertexArray;
    vertexArray ~= generateQuad(Side.Top, position + vec3f(0,0,0.5), facesij[0]);
    vertexArray ~= generateQuad(Side.Bottom, position + vec3f(0,0,-0.5), facesij[1]);
    vertexArray ~= generateQuad(Side.North, position + vec3f(0,0.5,0), facesij[2]);
    vertexArray ~= generateQuad(Side.South, position + vec3f(0,-0.5,0), facesij[3]);
    vertexArray ~= generateQuad(Side.East, position + vec3f(0.5,0,0), facesij[4]);
    vertexArray ~= generateQuad(Side.West, position + vec3f(-0.5,0,0), facesij[5]);
    uint[] indices = [
      0, 1, 2, 2, 1, 3, // south
      4, 5, 6, 6, 5, 7, // east
      8, 9,10,10, 9,11, // north
      12,13,14,14,13,15, // west
      16,17,18,18,17,19, // top
      20,21,22,22,21,23 // bottom
    ];
    auto mesh = Mesh!VertexPNT(vertexArray, indices);
    return new Model!VertexPNT(gl, setter, spec, mesh);
  }
}