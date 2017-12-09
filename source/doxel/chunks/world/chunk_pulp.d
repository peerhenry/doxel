import std.math;
import gfm.math;
import doxel_world;

class ChunkPulp: BaseRegion, IChunk
{
  private vec3i[int] worldSite;

  this(World world, IRegionContainer container, vec3i site)
  {
    assert(world !is null);
    assert(container !is null);
    assert(container.getRank() == 2);
    super(1, site);
    worldSite = buildWorldSite();
    container.addRegion(this);
  }

  private vec3i[int] buildWorldSite()
  {
    assert(worldSite == null);
    vec3i[int] newWorldSite;
    newWorldSite[1] = site;
    auto nextContainer = this.container;
    while(nextContainer !is null)
    {
      newWorldSite[nextContainer.getRank()] = nextContainer.getSite();
      nextContainer = nextContainer.getContainer();
    }
    return newWorldSite;
  }

  bool isPulp(){return true;}

  Block getBlock(int i, int j, int k)
  {
    return Block.PULP;
  }
}