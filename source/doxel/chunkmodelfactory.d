import gfm.math, gfm.opengl;

import engine;

import chunk, chunkmeshbuilder;

class ChunkModelFactory
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

  Model!VertexPNT generateChunkModel(Chunk chunk)
  {
    Mesh!VertexPNT mesh = buildChunkMesh(chunk);
    return new Model!VertexPNT(gl, setter, spec, mesh);
  }
}