import std.math;

import gfm.math, gfm.opengl;

import engine;

import chunk, chunkgameobject, chunkmeshbuilder, world, iregioncontainer;

class ChunkObjectFactory
{
  OpenGL gl;
  VertexSpecification!VertexPNT spec;
  UniformSetter!mat4f setter;
  World world;

  this(OpenGL gl, VertexSpecification!VertexPNT spec, UniformSetter!mat4f uniformSetter, World world)
  {
    this.gl = gl;
    this.spec = spec;
    this.setter = uniformSetter;
    this.world = world;
  }

  ChunkGameObject createChunkObject(Chunk chunk)
  {
    vec3i site = chunk.getSite();
    vec3f location = vec3f((site.x-4)*8.0, (site.y-4)*8.0, (site.z-2)*4.0);
    IRegionContainer container = chunk.getContainer();
    while(container !is null)
    {
      vec3f cSite = container.getSite();
      int rank = container.getRank();
      location.x = location.x + (cSite.x-4)*pow(8.0, rank);
      location.y += (cSite.y-4)*pow(8.0, rank);
      location.z += (cSite.z-2)*pow(4.0, rank);
      container = container.getContainer();
    }
    mat4f modelMatrix = mat4f.translation(location);
    Mat4fSetAction action = new Mat4fSetAction(setter, modelMatrix);
    Mesh!VertexPNT mesh = buildChunkMesh(this.world, chunk);
    Model!VertexPNT model = new Model!VertexPNT(gl, spec, mesh);
    ChunkGameObject chunkObject = new ChunkGameObject(null, action, model);

    return chunkObject;
  }
}