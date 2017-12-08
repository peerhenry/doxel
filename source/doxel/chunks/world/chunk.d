import std.math;
import gfm.math;
import doxel_world;

class Chunk: BaseRegion
{
  private World world;
  Block[regionCount] blocks;
  private vec3i[int] worldSite;

  this(World world, IRegionContainer container, vec3i site)
  {
    assert(world !is null);
    assert(container !is null);
    assert(container.getRank() == 2);
    super(1, site);
    this.world = world;
    this.container = container;
    container.addRegion(this);
    worldSite = buildWorldSite();
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

  /// Beware, the coordinates must be in bounds: 0<=i<8, 0<=j<8, 0<=k<4
  Block getBlock(int i, int j, int k)
  {
    int index = calculator.siteToIndex(i,j,k);
    return blocks[index];
  }

  void setBlock(int i, int j, int k, Block block)
  {
    int index = calculator.siteToIndex(i,j,k);
    blocks[index] = block;
  }

  void setAllBlocks(Block block)
  {
    blocks[] = block;
  }

  vec3i[int] getWorldSite()
  {
    return worldSite;
  }

  // obsolete?
  /*vec3i getGlobalSite()
  {
    return SiteCalculator.toGlobalSite(getWorldSite());
  }*/

  /// Gets position relative to world origin
  vec3f getPosition()
  {
    vec3i[int] worldSiteRef = world.getWorldSiteOrigin();
    return getPositionRelativeTo(worldSiteRef);
  }

  /// get this chunks position relative to given chunk.
  vec3f getPositionRelativeTo(Chunk chunk)
  {
    return getPositionRelativeTo(chunk.getWorldSite());
  }

  /// get this chunks position relative to a given worldsite.
  vec3f getPositionRelativeTo(vec3i[int] worldSiteRef)
  {
    return calculator.worldSiteRelativeTo(worldSite, worldSiteRef);
  }
}

unittest
{
  import testrunner;
  import sides;

  runtest("Chunk.d: Chunk position relative to itself is zero", delegate bool() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(1,1,1));
    // act
    vec3f d = chunk.getPositionRelativeTo(chunk);
    // assert
    assert(d.x < 0.01);
    assert(d.y < 0.01);
    assert(d.z < 0.01);
    return true;
  });

  runtest("Chunk.d: Chunk position relative to ds=(1,1,1) will return (8,8,4)", delegate bool() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(1,1,1));
    Chunk chunk2 = new Chunk(world, world.topRegion, vec3i(2,2,2));
    // act
    vec3f d = chunk2.getPositionRelativeTo(chunk);
    // assert
    assert(d.x == 8.0);
    assert(d.y == 8.0);
    assert(d.z == 4.0);
    return true;
  });

  runtest("Chunk.d: Chunk constructor gets assigned container", delegate bool(){
    // arrange
    World world = new World();
    auto reg1 = world.getCreateAdjacentRegion(world.topRegion, BottomDetails);
    IRegionContainer reg = cast(IRegionContainer)world.getCreateAdjacentRegion(reg1, BottomDetails);
    Chunk chunk = new Chunk(world, reg, vec3i(2,2,1));
    // act
    IRegionContainer result = chunk.getContainer();
    // assert
    assertEqual(reg, result);
    return true;
  });

  runtest("Chunk.d: chunk.getWorldSite() or two regions down", delegate bool(){
    // arrange
    World world = new World();
    auto reg1 = world.getCreateAdjacentRegion(world.topRegion, BottomDetails);
    IRegionContainer reg = cast(IRegionContainer)world.getCreateAdjacentRegion(reg1, BottomDetails);
    Chunk chunk = new Chunk(world, reg, vec3i(2,2,1));
    // act
    vec3i[int] result = chunk.getWorldSite();
    // assert
    assert((2 in result) !is null);
    assertEqual(vec3i(2,2,1), result[1]);
    assertEqual(vec3i(4,4,0), result[2]);
    return true;
  });

  runtest("Chunk.d: Chunk position relative to adjacent chunk in other region", delegate bool() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(0,0,0));
    Chunk chunk2 = cast(Chunk) (world.getCreateAdjacentRegion(chunk, BottomDetails));
    // act
    vec3f d = chunk2.getPositionRelativeTo(chunk);
    // assert
    assert(d.x == 0);
    assert(d.y == 0);
    assert(d.z == -4.0);
    return true;
  });

  runtest("Chunk.d: Chunk position relative chunk, two regions down", delegate bool() {
    // arrange
    World world = new World();
    auto reg1 = world.topRegion;
    auto regt = world.getCreateAdjacentRegion(world.topRegion, BottomDetails);
    IRegionContainer reg2 = cast(IRegionContainer)world.getCreateAdjacentRegion(regt, BottomDetails);
    Chunk chunk = new Chunk(world, reg1, vec3i(2,2,3));
    Chunk chunk2 = new Chunk(world, reg2, vec3i(2,2,1));
    // act
    vec3f d = chunk.getPositionRelativeTo(chunk2);
    // assert
    assertEqual(0, d.x);
    assertEqual(0, d.y);
    assertEqual(6*regionHeight + regionHeight*regionHeight, d.z);//6*4 + 16
    return true;
  });

  runtest("Chunk.d: identical to two regions down, but with world site", delegate bool() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(2,2,3));
    // act
    vec3f d = chunk.getPositionRelativeTo([1: vec3i(2,2,1), 2: vec3i(4,4,0)]);
    // assert
    assert(d.x == 0);
    assert(d.y == 0);
    assertEqual(6*regionHeight + regionHeight*regionHeight, d.z);//6*4 + 16
    return true;
  });
}