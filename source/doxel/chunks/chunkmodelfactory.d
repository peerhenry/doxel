import std.math;

import gfm.math, gfm.opengl;

import engine;

import chunk, chunkmeshbuilder, world, iregioncontainer;

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
    Model!VertexPNT model = new Model!VertexPNT(gl, setter, spec, mesh);
    vec3i site = chunk.getSite();
    vec3f location = vec3f((site.x-4)*8.0, (site.y-4)*8.0, (site.z-2)*4.0);
    IRegionContainer container = chunk.getContainer();
    if(container is null)
    {
      import std.stdio;
      writeln("A container was null for chunk at site: ");
      writeln(chunk.getSite().toString());
    }
    while(container !is null)
    {
      vec3f cSite = container.getSite();
      int rank = container.getRank();
      location.x = location.x + (cSite.x-4)*pow(8.0, rank);
      location.y += (cSite.y-4)*pow(8.0, rank);
      location.z += (cSite.z-2)*pow(4.0, rank);
      container = container.getContainer();
    }
    model.modelMatrix = mat4f.translation(location);
    return model;
  }
}