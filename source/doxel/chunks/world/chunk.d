import std.math;
import gfm.math;
import iregioncontainer, region, baseregion, blocks;

class Chunk: BaseRegion
{
  Block[256] blocks;

  this(IRegionContainer container, vec3i site)
  {
    assert(container !is null);
    super(1, site);
    this.container = container;
    container.addRegion(this);
  }

  /// Beware, the coordinates must be in bounds: 0<=i<8, 0<=j<8, 0<=k<4
  Block getBlock(int i, int j, int k)
  {
    int index = i + 8*j + 64*k;
    return blocks[index];
  }

  void setBlock(int i, int j, int k, Block block)
  {
    int index = i + 8*j + 64*k;
    blocks[index] = block;
  }

  void setAllBlocks(Block block)
  {
    blocks[] = block;
  }

  vec3i[int] getWorldSite()
  {
    vec3i[int] worldSite;
    worldSite[1] = site;
    auto nextContainer = container;
    while(nextContainer !is null)
    {
      worldSite[nextContainer.getRank()] = nextContainer.getSite();
      nextContainer = nextContainer.getContainer();
    }
    return worldSite;
  }

  vec3f getPositionFromWorldCenter()
  {
    vec3i[int] worldSiteRef;
    worldSiteRef[1] = vec3i(4,4,2);
    return getRelativePositionFrom(worldSiteRef);
  }

  /// get this chunks position relative to given chunk.
  vec3f getRelativePositionFrom(Chunk chunk)
  {
    return getRelativePositionFrom(chunk.getWorldSite());
  }

  /// get this chunks position relative to a given worldsite.
  vec3f getRelativePositionFrom(vec3i[int] worldSiteRef)
  {
    vec3i[int] worldSite = this.getWorldSite();
    vec3f relPos = vec3f(0,0,0);
    int nextRank = 1;
    bool RefSiteHasNext, thisSiteHasNext = true;
    while(RefSiteHasNext || thisSiteHasNext)
    {
      RefSiteHasNext = (nextRank in worldSiteRef) !is null;
      thisSiteHasNext = (nextRank in worldSite) !is null;
      vec3i nextRefSite = RefSiteHasNext ? worldSiteRef[nextRank] : vec3i(4,4,2);
      vec3i nextSite = thisSiteHasNext ? worldSite[nextRank] : vec3i(4,4,2);
      relPos.x += (nextSite.x - nextRefSite.x)*pow(8, nextRank);
      relPos.y += (nextSite.y - nextRefSite.y)*pow(8, nextRank);
      relPos.z += (nextSite.z - nextRefSite.z)*pow(4, nextRank);
      nextRank++;
    }
    return relPos;
  }
}