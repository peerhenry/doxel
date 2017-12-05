import gfm.math;

enum Side
{
  Top,
  Bottom,
  North,
  South,
  East,
  West
}

struct SideDetails
{
  Side side;
  vec3f normal;
  vec3i normali;

  this(Side side, vec3f normal)
  {
    this.side = side;
    this.normal = normal;
    this.normali = cast(vec3i)normal;
  }
}

static const SideDetails TopDetails = SideDetails(Side.Top, vec3f(0,0,1));
static const SideDetails BottomDetails =  SideDetails(Side.Bottom, vec3f(0,0,-1));
static const SideDetails NorthDetails = SideDetails(Side.North, vec3f(0,1,0));
static const SideDetails SouthDetails = SideDetails(Side.South, vec3f(0,-1,0));
static const SideDetails EastDetails = SideDetails(Side.East, vec3f(1,0,0));
static const SideDetails WestDetails = SideDetails(Side.West, vec3f(-1,0,0));

const SideDetails[] allSides = [
  TopDetails,
  BottomDetails,
  NorthDetails,
  SouthDetails,
  EastDetails,
  WestDetails
];