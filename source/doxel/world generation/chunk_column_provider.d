import gfm.math:vec2i;
import world_surface_generator, doxel_world;

class ChunkColumnProvider
{
  private{
    World _world;
    WorldSurfaceGenerator _generator;
    Chunk[][int][int] _dic;
  }

  this(World world, WorldSurfaceGenerator generator)
  {
    _generator = generator;
    _world = world;
  }

  Chunk[] getColumn(vec2i site)
  {
    Chunk[] col = retrieveAtSite(site);
    if(col is null){
      _generator.generateChunkColumn(site);
      col = _world.getNewChunks();
      _dic[site.x][site.y] = col;
      _world.clearNewChunks();
    }
    return col;
  }

  private Chunk[] retrieveAtSite(vec2i site)
  {
    Chunk[][int]* dic1 = site.x in _dic;
    if(dic1 is null) return null;
    Chunk[]* val = site.y in *dic1;
    if(val is null) return null;
    return *val;
  }
}