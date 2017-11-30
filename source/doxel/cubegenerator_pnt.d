import gfm.opengl, gfm.math;

import engine;

import quadgenerator_pnt;

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

  Model!VertexPNT generateCube(vec3f position)
  {
    VertexPNT[] vertexArray;
    vertexArray ~= generateQuad(Side.Top, position + vec3f(0,0,0.5), vec2i(0,0));
    vertexArray ~= generateQuad(Side.Bottom, position + vec3f(0,0,-0.5), vec2i(2,0));
    vertexArray ~= generateQuad(Side.North, position + vec3f(0,0.5,0), vec2i(3,0));
    vertexArray ~= generateQuad(Side.South, position + vec3f(0,-0.5,0), vec2i(3,0));
    vertexArray ~= generateQuad(Side.East, position + vec3f(0.5,0,0), vec2i(3,0));
    vertexArray ~= generateQuad(Side.West, position + vec3f(-0.5,0,0), vec2i(3,0));
    uint[] indices = [
      0, 1, 2, 2, 1, 3, // south
      4, 5, 6, 6, 5, 7, // east
      8, 9,10,10, 9,11, // north
      12,13,14,14,13,15, // west
      16,17,18,18,17,19, // top
      20,21,22,22,21,23 // bottom
    ];
    return new Model!VertexPNT(gl, setter, spec, vertexArray, indices);
  }
}