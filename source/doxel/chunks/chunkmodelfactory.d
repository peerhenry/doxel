import gfm.math, gfm.opengl;

import engine;

import chunk, chunkmeshbuilder, world;

class ChunkModelFactory
{
  OpenGL gl;
  VertexSpecification!VertexPNT spec;
  ModelSetter setter;
  World world;

  this(OpenGL gl, VertexSpecification!VertexPNT spec, ModelSetter modelSetter, World world)
  {
    this.gl = gl;
    this.spec = spec;
    this.setter = modelSetter;
    this.world = world;
  }

  Model!VertexPNT generateChunkModel(Chunk chunk)
  {
    Mesh!VertexPNT mesh = buildChunkMesh(this.world, chunk);
    return new Model!VertexPNT(gl, setter, spec, mesh);
  }
}